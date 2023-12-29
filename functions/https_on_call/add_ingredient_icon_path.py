import logging
import json


import google.cloud.firestore
from firebase_admin import firestore
from firebase_functions import https_fn
from fuzzywuzzy import process
from openai import OpenAI


@https_fn.on_call(secrets=["OPENAI_API_KEY"], timeout_sec=120)
def add_ingredient_icon_path_to_recipe(req: https_fn.CallableRequest):
    logging.info(f"Starting add_ingredient_icon_path with request: {req}")
    try:
        recipe, ingredients_ref, ingredient_docs = get_recipe_and_ingredients(
            req)

        client = OpenAI()

        for ingredient in recipe['ingredients']:
            process_ingredient(ingredient, ingredient['name'], ingredient_docs,
                               client, ingredients_ref)

        update_recipe(recipe)

        return {'status': 'success'}
    except Exception as e:
        logging.error('Error during ingredient icon path addition: %s', str(e))
        return {'status': 'error', 'error': str(e)}


@https_fn.on_call(secrets=["OPENAI_API_KEY"], timeout_sec=120)
def add_ingredient_icon_path_to_list(req: https_fn.CallableRequest):
    logging.info(
        f"Starting add_ingredient_icon_path_to_list with request: {req}")
    try:
        list, ingredients_ref, ingredient_docs = get_list_and_ingredients(req)

        client = OpenAI()

        for ingredient in list['ingredients']:
            process_ingredient(
                ingredient, ingredient['name'], ingredient_docs, client, ingredients_ref)

        update_list(list)

        return {'status': 'success'}
    except Exception as e:
        logging.error('Error during ingredient icon path addition: %s', str(e))
        return {'status': 'error', 'error': str(e)}


def process_ingredient(ingredient, ingredient_name, ingredient_docs, client, ingredients_ref):
    matched_ingredients = get_matched_ingredients(
        ingredient_name, ingredient_docs)

    if not matched_ingredients:
        logging.info(
            'No matched ingredients found, creating a new ingredient document')
        create_and_set_new_ingredient(
            ingredient, ingredient_name, client, ingredients_ref)
    else:
        ingredient_id = get_ingredient_id(
            ingredient,
            matched_ingredients, client, ingredients_ref)
        if ingredient_id == '':
            logging.info(
                'No appropriate match found, creating a new ingredient document')
            create_and_set_new_ingredient(
                ingredient, ingredient_name, client, ingredients_ref)
        else:
            logging.info(
                f'Appropriate match found for ingredient: {ingredient_name}')
            ingredient['meta']['ingredientId'] = ingredient_id
            # TODO: We read this already before we can remove the unecessary read.
            ingredient_doc = ingredients_ref.document(ingredient_id).get()
            ingredient['meta']['iconPath'] = ingredient_doc.get('iconPath')


def create_and_set_new_ingredient(ingredient, ingredient_name, client, ingredients_ref):
    new_ingredient = create_new_ingredient(ingredient_name, client)
    doc_ref = ingredients_ref.document()
    logging.info(f"New document reference: {doc_ref.id}")  # Added this line
    doc_ref.set(new_ingredient)
    # Set ingredientId to new document ID
    ingredient['meta']['ingredientId'] = doc_ref.id


def create_new_ingredient(ingredient_name, client):
    return {
        "name": ingredient_name,
        "iconPath": '',
        # "embedding": list(client.embeddings.create(
        #     model="text-embedding-ada-002",
        #     input=ingredient_name,
        #     encoding_format="float"
        # ).data[0].embedding)
    }


def get_matched_ingredients(ingredient_name, ingredient_docs):
    logging.info(
        f'Starting get_matched_ingredients function for ingredient: {ingredient_name}')
    ingredient_names = [doc['name'] for doc in ingredient_docs]
    matches = process.extract(ingredient_name, ingredient_names, limit=3)
    matched_ingredients = [doc for doc in ingredient_docs if doc['name'] in [
        ingredient for ingredient, score in matches if score > 55]]
    logging.info(
        f'Matched ingredients for {ingredient_name}: {matched_ingredients}')

    return matched_ingredients


def get_ingredient_id(ingredient, matched_ingredients, client, ingredients_ref):
    logging.info('Starting get_ingredient_id function...')
    content = "\n".join([f"{i}. {ingredient['name']}" for i,
                        ingredient in enumerate(matched_ingredients)])
    logging.info(f'Content for OpenAI completion: {content}')
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
    logging.info(f'Index from OpenAI completion: {index}')
    if index == -1:
        logging.info('No appropriate match found, returning empty string')
        return ''
    else:
        logging.info(f'INDEX: {matched_ingredients[index]}')
        logging.info(
            f"Appropriate match found, returning ingredient id {matched_ingredients[index]['id']}")
        return matched_ingredients[index]['id']


def get_list_and_ingredients(req):
    logging.info('Starting get_list_and_ingredients function...')
    list_id = req.data['list_id']
    logging.info(f'List ID: {list_id}')
    db: google.cloud.firestore.Client = firestore.client()

    list_ref = db.collection('lists').document(list_id)
    list = list_ref.get().to_dict()
    list['id'] = list_id
    logging.info(f'Retrieved list: {list}')

    ingredients_ref = db.collection('ingredients')
    docs = ingredients_ref.stream()
    ingredient_docs = [{**doc.to_dict(), 'id': doc.id} for doc in docs]
    logging.info(f'Retrieved {len(ingredient_docs)} ingredient documents')

    return list, ingredients_ref, ingredient_docs


def get_recipe_and_ingredients(req):
    logging.info('Starting get_recipe_and_ingredients function...')
    recipe_id = req.data['recipe_id']
    logging.info(f'Recipe ID: {recipe_id}')
    db: google.cloud.firestore.Client = firestore.client()

    recipe_ref = db.collection('recipes').document(recipe_id)
    recipe = recipe_ref.get().to_dict()
    recipe['id'] = recipe_id
    logging.info(f'Retrieved recipe: {recipe}')

    ingredients_ref = db.collection('ingredients')
    docs = ingredients_ref.stream()
    ingredient_docs = [{**doc.to_dict(), 'id': doc.id} for doc in docs]
    logging.info(f'Retrieved {len(ingredient_docs)} ingredient documents')

    return recipe, ingredients_ref, ingredient_docs


def update_recipe(recipe):
    db: google.cloud.firestore.Client = firestore.client()

    recipe_ref = db.collection('recipes').document(recipe['id'])
    recipe_ref.update({"ingredients": recipe['ingredients']})


def update_list(list):
    db: google.cloud.firestore.Client = firestore.client()

    list_ref = db.collection('lists').document(list['id'])
    list_ref.update({"ingredients": list['ingredients']})
