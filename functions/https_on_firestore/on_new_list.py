import asyncio
from fuzzywuzzy import fuzz, process
from firebase_admin import firestore
import google.cloud.firestore
from firebase_functions import on_document_created 
from openai import OpenAI


@on_document_created(document='recipes/{recipeId}')
def on_new_recipe(data, context):
    # This function will be triggered when a new document is created in the 'recipes' collection
    # 'data' contains the document data
    # 'context' contains metadata about this document
    print(f'A new recipe was created: {data}')

@on_document_created(document='lists/{listId}')
def on_new_list(data, context):
    # This function will be triggered when a new document is created in the 'lists' collection
    # 'data' contains the document data
    # 'context' contains metadata about this document
    print(f'A new list was created: {data}')


async def get_icon_for_ingredient(ingredient, ingredient_names, ingredients_ref, client):
    matches = process.extract(ingredient, ingredient_names, limit=5)
    matched_ingredients = [ingredient for ingredient,
                           score in matches if score > 55]
    if not matched_ingredients:
        # Create a new ingredient document without an image url
        new_ingredient = {"name": ingredient, "icon": -1}
        doc_ref = ingredients_ref.document()  # Create a new document reference
        doc_ref.set(new_ingredient)  # Set the new ingredient document
        # Return the document id
        return {"ingredient": ingredient, "icon": -1, "doc_id": doc_ref.id}
    else:
        content = "\n".join(
            [f"{i}. {ingredient}" for i, ingredient in enumerate(matched_ingredients)])
        message = {
            "role": "user",
            "content": f"Find an appropriate icon for the following ingredients or return -1 for each. Use json format {{'index': int, 'icon': int}}\n{content}"
        }
        completion = await client.chat.completions.create(
            model="gpt-3.5-turbo-1106",
            messages=[message],
            response_format={'type': 'json_object'}
        )
        index = completion.choices[0].message.content['index']
        if index == -1:
            new_ingredient = {"name": ingredient, "icon": -1}
            doc_ref = ingredients_ref.document()  # Create a new document reference
            doc_ref.set(new_ingredient)  # Set the new ingredient document
            # Return the document id
            return {"ingredient": ingredient, "icon": -1, "doc_id": doc_ref.id}
        else:
            doc_ref = ingredients_ref.document(matched_ingredients[index])
            # Return the document id of the matched ingredient
            return {"ingredient": ingredient, "icon": index, "doc_id": doc_ref.id}


async def get_ingredient_icons(ingredient_list):
    db = firestore.Client()
    ingredients_ref = db.collection('ingredients')
    docs = ingredients_ref.stream()

    ingredient_docs = [doc.to_dict() for doc in docs]
    ingredient_names = [doc['name'] for doc in ingredient_docs]

    client = OpenAI()

    tasks = [get_icon_for_ingredient(
        ingredient, ingredient_names, ingredients_ref, client) for ingredient in ingredient_list]
    results = await asyncio.gather(*tasks)

    return results
