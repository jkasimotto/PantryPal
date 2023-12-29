import asyncio
import logging
from fuzzywuzzy import fuzz, process
from firebase_admin import firestore
from firebase_functions.firestore_fn import on_document_updated, Change, Event, DocumentSnapshot
from openai import OpenAI

logging.basicConfig(level=logging.INFO)


@https(document='recipes/{recipeId}')
def on_recipe_updated(event: Event[Change[DocumentSnapshot]]):
    before_data = event.data.before.get('data')
    after_data = event.data.after.get('data')
    logging.info('A recipe is being updated')

    # TODO: Go from here. Check if ingredients names' are different.
    # Then start with synchronous iterating over each ingredient.
    
    # Check if the ingredients have changed
    if before_data.get('ingredients') != after_data.get('ingredients'):
        logging.info(f'A recipe was updated: {after_data}')
        
        # Check if the updated document has ingredients
        if after_data.get('ingredients') is not None:
            ingredient_icons = get_ingredient_icons(after_data.get('ingredients'))
            logging.info(f'Ingredient icons: {ingredient_icons}')
        else:
            logging.info('No ingredients found in the updated recipe')


@on_document_updated(document='lists/{listId}')
def on_new_list(data, context):
    logging.info('A new list is being created')
    # This function will be triggered when a new document is created in the 'lists' collection
    # 'data' contains the document data
    # 'context' contains metadata about this document
    logging.info(f'A new list was created: {data}')

