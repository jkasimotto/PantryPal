import json
import logging
import os
import uuid
from typing import List, Tuple, Union
from fuzzywuzzy import fuzz, process

import google.cloud.firestore
from firebase_admin import firestore, storage
from firebase_functions import https_fn
from google.cloud.firestore import DocumentReference
from model.firestore.recipe import Ingredient, IngredientMeta, Recipe
from model.firestore.shopping_list import ShoppingList
from openai import OpenAI

@https_fn.on_call(timeout_sec=120)
def list_file_names(req: https_fn.CallableRequest) -> dict:
    path = req.data.get('path')
    if not path:
        return {'status': 'error', 'error': 'No path provided'}

    try:
        file_names = get_file_names(path)
        return {'status': 'success', 'file_names': file_names}
    except Exception as e:
        logging.error('Error during file listing: %s', str(e))
        return {'status': 'error', 'error': str(e)}


@https_fn.on_call(secrets=["OPENAI_API_KEY"], timeout_sec=120)
def add_ingredient_icon_path_to_entity(req: https_fn.CallableRequest) -> dict:
    entity_type = req.data.get('entity_type')
    logging.info(f"Starting add_ingredient_icon_path with request: {req}")
    try:
        if entity_type not in ['recipe', 'list']:
            return {'status': 'error', 'error': 'Invalid entity type'}

        entity = get_entity(req, entity_type)

        ingredient_docs, ingredients_ref = get_all_ingredients()
        ingredient_icon_paths = get_all_ingredient_icons()

        client = OpenAI()
        for ingredient in entity.ingredients:  # type: Ingredient
            if not ingredient.meta.iconPath or ingredient.meta.iconPath.endswith('default.png'):
                process_ingredient(ingredient, client,
                                   ingredient_docs, ingredients_ref, ingredient_icon_paths)

        update_entity(entity, entity_type)

        return {'status': 'success'}
    except Exception as e:
        logging.error('Error during ingredient icon path addition: %s', str(e))
        return {'status': 'error', 'error': str(e)}


def process_ingredient(ingredient: Ingredient, client: OpenAI, ingredient_docs: List[Ingredient], ingredients_ref: DocumentReference, ingredient_icons: List[str]) -> None:
    fuzzy_matched_ingredients = get_fuzzy_matched_ingredients(
        ingredient.name, ingredient_docs)

    if not fuzzy_matched_ingredients:
        handle_no_fuzzy_matches(
            ingredient, ingredients_ref, ingredient_icons, client)
    else:
        handle_fuzzy_matches(
            ingredient, fuzzy_matched_ingredients, client, ingredients_ref, ingredient_icons)


def handle_no_fuzzy_matches(ingredient: Ingredient, ingredients_ref: DocumentReference, ingredient_icons: List[str], client: OpenAI) -> None:
    logging.info('No fuzzy matches found, creating a new ingredient document')
    create_and_set_new_ingredient(ingredient, ingredients_ref, ingredient_icons, client)


def handle_fuzzy_matches(ingredient: Ingredient, fuzzy_matched_ingredients: List[Ingredient], client: OpenAI, ingredients_ref: DocumentReference, ingredient_icons: List[str]) -> None:
    ai_matched_ingredient_id = get_ai_matched_ingredient_id(
        ingredient, fuzzy_matched_ingredients, client, ingredients_ref)
    if ai_matched_ingredient_id == '':
        handle_no_ai_match(ingredient, client, ingredients_ref, ingredient_icons)
    else:
        handle_ai_match(ingredient, ai_matched_ingredient_id, ingredients_ref)


def handle_no_ai_match(ingredient: Ingredient, client: OpenAI, ingredients_ref: DocumentReference, ingredient_icons: List[str]) -> None:
    logging.info(
        'No appropriate AI match found, creating a new ingredient document')
    create_and_set_new_ingredient(ingredient, ingredients_ref, ingredient_icons, client)


def handle_ai_match(ingredient: Ingredient, ai_matched_ingredient_id: str, ingredients_ref: DocumentReference) -> None:
    logging.info(
        f'Appropriate AI match found for ingredient: {ingredient.name}')
    ingredient.meta.ingredientId = ai_matched_ingredient_id
    matched_ingredient = get_ingredient(
        ai_matched_ingredient_id, ingredients_ref)
    ingredient.meta.iconPath = matched_ingredient.meta.iconPath


def create_and_set_new_ingredient(ingredient: Ingredient, ingredients_ref: DocumentReference, ingredient_icons: List[str], client: OpenAI) -> None:
    new_ingredient: Ingredient = create_new_ingredient(ingredient.name, ingredient_icons, client)
    doc_ref = ingredients_ref.document(new_ingredient.meta.ingredientId)
    logging.info(f"New document reference: {doc_ref.id}")
    doc_ref.set(new_ingredient.dict(
        exclude_none=True,
        exclude_unset=True,
        exclude_defaults=True

    ))
    ingredient.meta.ingredientId = new_ingredient.meta.ingredientId
    ingredient.meta.iconPath = new_ingredient.meta.iconPath


def create_new_ingredient(ingredient_name: str, ingredient_icons: List[str], client: OpenAI) -> Ingredient:
    ingredient_id = str(uuid.uuid4())
    top_icon_paths = get_best_icon_matches(ingredient_name, ingredient_icons)
    icon_path = ai_select_best_icon(ingredient_name, top_icon_paths, client)
    return Ingredient(
        name=ingredient_name,
        meta=IngredientMeta(
            iconPath=icon_path,
            ingredientId=ingredient_id
        )
    )


def get_best_icon_matches(ingredient_name: str, ingredient_icons: List[str], limit: int = 5) -> List[str]:
    matches = process.extract(ingredient_name, ingredient_icons, limit=limit)
    return [f'assets/images/icons/food/{match[0]}.png' for match in matches if match[1] > 55]


def ai_select_best_icon(ingredient: Ingredient, icon_paths: List[str], client: OpenAI) -> str:
    content = "\n".join([f"{i}. {path}" for i, path in enumerate(icon_paths)])
    message = {
        "role": "user",
        "content": f"Select the best match for the ingredient {ingredient} or return -1. Use json format {{'index': int}}\n{content}"
    }
    completion = client.chat.completions.create(
        model="gpt-4-1106-preview",
        messages=[message],
        response_format={'type': 'json_object'}
    )
    index = json.loads(completion.choices[0].message.content)['index']
    if index == -1:
        return 'assets/images/icons/food/default.png'
    else:
        return icon_paths[index]


def get_fuzzy_matched_ingredients(ingredient_name: str, ingredient_docs: List[Ingredient]) -> List[Ingredient]:
    logging.info(
        f'Starting get_fuzzy_matched_ingredients function for ingredient: {ingredient_name}')
    ingredient_names = [doc.name for doc in ingredient_docs]
    matches = process.extract(ingredient_name, ingredient_names, limit=3)
    fuzzy_matched_ingredients = [doc for doc in ingredient_docs if doc.name in [
        ingredient for ingredient, score in matches if score > 55]]
    logging.info(
        f'Fuzzy matched ingredients for {ingredient_name}: {fuzzy_matched_ingredients}')

    return fuzzy_matched_ingredients


def get_ai_matched_ingredient_id(ingredient: Ingredient, fuzzy_matched_ingredients: List[Ingredient], client: OpenAI, ingredients_ref: DocumentReference) -> str:
    logging.info('Starting AI matching process...')
    content = "\n".join([f"{i}. {ingredient.name}" for i,
                        ingredient in enumerate(fuzzy_matched_ingredients)])
    logging.info(f'Content for AI matching: {content}')
    message = {
        "role": "user",
        "content": f"Select the best match for the ingredient {ingredient} or return -1. Use json format {{'index': int}}\n{content}"
    }
    completion = client.chat.completions.create(
        model="gpt-4-1106-preview",
        messages=[message],
        response_format={'type': 'json_object'}
    )
    index = json.loads(completion.choices[0].message.content)['index']
    logging.info(f'Index from AI matching: {index}')
    if index == -1:
        logging.info('No appropriate AI match found, returning empty string')
        return ''
    else:
        logging.info(
            f'AI Matched Ingredient: {fuzzy_matched_ingredients[index]}')
        logging.info(
            f"Appropriate AI match found, returning ingredient id {fuzzy_matched_ingredients[index].meta.ingredientId}")
        return fuzzy_matched_ingredients[index].meta.ingredientId


def get_entity(req: https_fn.CallableRequest, entity_type: str) -> Union[Recipe, ShoppingList]:
    logging.info(f'Starting get_{entity_type} function...')
    entity_id = req.data['entity_id']
    logging.info(f'{entity_type.capitalize()} ID: {entity_id}')
    db: google.cloud.firestore.Client = firestore.client()

    entity_ref = db.collection(entity_type+'s').document(entity_id)
    entity = entity_ref.get().to_dict()
    entity['id'] = entity_id
    logging.info(f'Retrieved {entity_type}: {entity}')

    # Convert entity to Pydantic model
    if entity_type == 'recipe':
        entity = Recipe(**entity)
    elif entity_type == 'list':
        entity = ShoppingList(**entity)

    return entity


def update_entity(entity: Union[Recipe, ShoppingList], entity_type: str) -> None:
    db: google.cloud.firestore.Client = firestore.client()

    entity_ref = db.collection(entity_type+'s').document(entity.id)
    entity_ref.update(entity.dict())


def get_all_ingredients() -> Tuple[List[Ingredient], DocumentReference]:
    db: google.cloud.firestore.Client = firestore.client()
    ingredients_ref = db.collection('ingredients')
    docs = ingredients_ref.stream()
    ingredient_docs = [Ingredient(**doc.to_dict(), id=doc.id) for doc in docs]
    return ingredient_docs, ingredients_ref


def get_ingredient(ingredient_id: str, ingredients_ref: DocumentReference) -> Ingredient:
    doc = ingredients_ref.document(ingredient_id).get()
    return Ingredient(**doc.to_dict(), id=doc.id)


def get_file_names(path: str) -> list:
    bucket = storage.bucket()
    blobs = bucket.list_blobs(prefix=path)  # Get list of files
    file_names = []
    for blob in blobs:
        base_name = os.path.basename(blob.name)  # Get the base name of the file
        file_name = os.path.splitext(base_name)[0]  # Remove the extension
        file_names.append(file_name)
    return file_names


def get_all_ingredient_icons() -> list:
    path = 'assets/images/icons/food/'
    return get_file_names(path)