from google.cloud import firestore
import json
import logging
import time
from typing import Dict, List

from firebase_functions import https_fn
from model.model import Recipe, ShoppingListIngredient
from util.logging import log_performance
from util.pydantic import convert_enum_to_value

from openai import OpenAI


@https_fn.on_call(secrets=["OPENAI_API_KEY"], timeout_sec=120)
def combine_ingredients(req: https_fn.CallableRequest) -> Dict:
    start_time = time.time()
    logging.info(f"Starting combine_ingredients with request: {req}")
    try:
        logging.info(
            f"Received ingredient combination request at {time.ctime(start_time)}")
        # user_id = req.auth.uid
        # logging.info(f"User ID: {user_id}")
        recipes = req.data['recipes']
        logging.info(f"Recipes before json.loads: {recipes}")
        recipes: List[Recipe] = json.loads(recipes)
        logging.info(f"Recipes after json.loads: {recipes}")
        ingredients = extract_ingredients(recipes)
        logging.info(f"Extracted ingredients: {ingredients}")
        client = OpenAI()
        reasoning_reply = handle_reasoning_completion(client, ingredients)
        logging.info(f"Reasoning reply: {reasoning_reply}")
        combined_ingredients: List[ShoppingListIngredient] = handle_tool_extraction(client, reasoning_reply)
        logging.info(f"Combined ingredients: {combined_ingredients}")
        combined_ingredients_json = json.dumps(
            [ingredient.dict() for ingredient in combined_ingredients])
        logging.info(f"Combined ingredients json {combined_ingredients_json}")
        return {'status': 'success', 'ingredients': combined_ingredients_json}
    except Exception as e:
        logging.error('Error during ingredient combination: %s', str(e))
        log_performance(start_time, "Failed ingredient combination")
        return {'status': 'error', 'error': str(e)}


def extract_ingredients(recipes: List[Recipe]) -> List[Dict]:
    logging.info(f"Extracting ingredients from recipes: {recipes}")
    nested_ingredients = [(ingredient['ingredientData']['name'],
                           ingredient['quantity'],
                           ingredient['units'],
                           ingredient['ingredientData']['form'],
                           ingredient['ingredientData']['category'])
                          for recipe in recipes for ingredient in recipe['data']['ingredients']]
    ingredients = [{'name': name, 'quantity': quantity, 'units': units, 'form': form, 'category': category}
                   for name, quantity, units, form, category in nested_ingredients]
    logging.info(f"Extracted nested ingredients: {ingredients}")
    return ingredients


def handle_reasoning_completion(client: OpenAI, ingredients: List[Dict]) -> str:
    ingredients_text = ', '.join(
        [f"{ingredient['name']}: {ingredient['quantity']}, {ingredient['form']}, {ingredient['category']}" for ingredient in ingredients])
    reasoning_message = {
        "role": "user",
        "content": f"""
        1. First look at which ingredients are the same (e.g. carrots and carrot are the same but tomatos and cherry tomatos are not)
        2. Go through and convert the units into one sensible unit and then sum their amounts. 
        3. Write the final list under FINAL LIST. You must write FINAL LIST before the final list.

        Example:
        1 Tomato
        3 eggs
        2 packets egg noodles
        3 cherry tomatos
        4 large tomatos

        1. Tomato is the same as large tomato and can be grouped together. But cherry tomato is distinctly different. Eggs and eggs noodles are different.
        The list of unique ingredients is tomato, eggs, egg noodles and cherry tomatos.
        2. There is 1 tomato + 4 large tomatos to make 5 large tomatos. There are 3 eggs. There are 2 packets of egg noodles. There are 3 cherry tomatos.

        FINAL LIST:
        5 large tomatos
        3 eggs
        2 packets egg noodles
        3 cherry tomatos
        
        Here are the ingredients: {ingredients_text}"""

    }
    reasoning_completion = client.chat.completions.create(
        model="gpt-4-1106-preview",
        messages=[reasoning_message]
    )
    return reasoning_completion.choices[0].message.content.split('FINAL LIST')[1]


def handle_tool_extraction(client: OpenAI, reasoning_reply: str) -> List[ShoppingListIngredient]:
    logging.info("Starting tool extraction.")
    tool_message = {
        "role": "user",
        "content": reasoning_reply
    }
    logging.info(f"Tool message: {tool_message}")
    messages = [
        tool_message,
        {
            "role": "user",
            "content": "Extract the final ingredients into a list."
        }
    ]
    logging.info(f"Messages: {messages}")
    ingredient_schema = ShoppingListIngredient.schema()
    json_schema = {
        "type": "object",
        "properties": {
            "ingredients": {
                "type": "array",
                "items": ingredient_schema
            }
        },
        "required": ["ingredients"]
    }
    logging.info(f"JSON schema: {json_schema}")
    tools = [
        {
            "type": "function",
            "function": {
                "name": "combine_ingredients",
                "description": "Extract the final ingredient list from multiple recipes.",
                "parameters": json_schema
            }
        }
    ]
    logging.info(f"Tools: {tools}")
    completion = client.chat.completions.create(
        model="gpt-4-1106-preview",
        messages=messages,
        tools=tools,
        tool_choice={"type": "function", "function": {
            "name": "combine_ingredients"}}
    )
    logging.info(f"Completion: {completion}")
    reply = completion.choices[0].message.tool_calls[0].function.arguments
    logging.info(f"Reply: {reply}")
    combined_ingredients = json.loads(reply)
    combined_ingredients = combined_ingredients['ingredients']
    logging.info(f"Combined ingredients: {combined_ingredients}")
    shopping_list_ingredients: List[ShoppingListIngredient] = [ShoppingListIngredient.parse_obj(
        ingredient) for ingredient in combined_ingredients]
    logging.info(f"Shopping list ingredients: {shopping_list_ingredients}")
    return shopping_list_ingredients