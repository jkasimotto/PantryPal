import json
import logging
import os
import time
from typing import Dict, List

from firebase_functions import https_fn
from google.cloud import firestore
from model.convert import convert_to_firestore_ingredient
from model.extraction.shopping_list import \
    ShoppingListIngredient as ShoppingListIngredientExtracted
from model.firestore.recipe import IngredientWithQuantity, Recipe
from model.firestore.shopping_list import \
    ShoppingListIngredient as ShoppingListIngredientFirestore
from openai import OpenAI
from util.logging import log_performance
from util.pydantic import convert_enum_to_value

# At the module level
REASONING_MESSAGE_TEMPLATE = """
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

Here are the ingredients: {}
"""

# Constants for tool extraction
TOOL_EXTRACTION_MESSAGE = "Extract the final ingredients into a list."
TOOL_FUNCTION_NAME = "combine_ingredients"
TOOL_FUNCTION_DESCRIPTION = "Extract the final ingredient list from multiple recipes."


@https_fn.on_call(secrets=["OPENAI_LIST_COMBINATION_API_KEY"], timeout_sec=120)
def combine_ingredients(req: https_fn.CallableRequest) -> Dict:
    start_time = log_start(req)
    try:
        recipes = parse_recipes(req)
        ingredients = extract_ingredients(recipes)
        ai_assistant = AIIngredientAssistant(
            OpenAI(api_key=os.getenv('OPENAI_LIST_COMBINATION_API_KEY')))

        reasoning_reply = ai_assistant.get_reasoning(ingredients)
        combined_ingredients = ai_assistant.get_combined_ingredients(
            reasoning_reply)
        combined_ingredients_json = convert_ingredients_to_json(
            combined_ingredients)

        return {'status': 'success', 'ingredients': combined_ingredients_json}
    except Exception as e:
        logging.error('Error during ingredient combination: %s', str(e))
        log_performance(start_time, "Failed ingredient combination")
        return {'status': 'error', 'error': str(e)}


def log_start(req: https_fn.CallableRequest) -> float:
    start_time = time.time()
    logging.info(f"Starting combine_ingredients with request: {req}")
    logging.info(
        f"Received ingredient combination request at {time.ctime(start_time)}")
    return start_time


def parse_recipes(req: https_fn.CallableRequest) -> List[Recipe]:
    recipes = req.data['recipes']
    logging.info(f"Recipes before json.loads: {recipes}")
    recipes_dict_list: List[dict] = json.loads(recipes)
    logging.info(f"Recipes after json.loads: {recipes_dict_list}")
    return [Recipe.parse_obj(recipe_dict) for recipe_dict in recipes_dict_list]


def convert_ingredients_to_json(combined_ingredients: List[ShoppingListIngredientExtracted]) -> str:
    combined_ingredients_json = json.dumps(
        [ingredient.dict() for ingredient in combined_ingredients])
    logging.info(f"Combined ingredients json {combined_ingredients_json}")
    return combined_ingredients_json


def extract_ingredients(recipes: List[Recipe]) -> List[Dict]:
    logging.info(f"Extracting ingredients from recipes: {recipes}")
    # Flatten the list of ingredients from all recipes into a single list
    flattened_ingredients = [
        ingredient for recipe in recipes for ingredient in recipe.ingredients]
    logging.info(f"Extracted flattened ingredients: {flattened_ingredients}")
    return flattened_ingredients


class AIIngredientAssistant:
    def __init__(self, client: OpenAI):
        self.client = client

    def get_reasoning(self, ingredients: List[IngredientWithQuantity]) -> str:
        ingredients_text = self._format_ingredients(ingredients)
        reasoning_message = self._format_reasoning_message(ingredients_text)
        return self._handle_reasoning_completion(reasoning_message)

    def get_combined_ingredients(self, reasoning_reply: str) -> List[ShoppingListIngredientFirestore]:
        return self._handle_tool_extraction(reasoning_reply)

    def _format_ingredients(self, ingredients: List[IngredientWithQuantity]) -> str:
        return ', '.join(
            [f"{ingredient.name}: {ingredient.quantity.amount} {ingredient.quantity.units}, {ingredient.form}, {ingredient.category}"
             for ingredient in ingredients])

    def _format_reasoning_message(self, ingredients_text: str) -> str:
        return REASONING_MESSAGE_TEMPLATE.format(ingredients_text)

    def _handle_reasoning_completion(self, reasoning_message: str) -> str:
        reasoning_completion = self.client.chat.completions.create(
            model="gpt-4-1106-preview",
            messages=[{"role": "user", "content": reasoning_message}]
        )
        logging.info(
            f"AI reasoning completion: {reasoning_completion.choices[0].message.content}")
        logging.info(
            f"List Combination Reasoning Completion Usage: {reasoning_completion.usage}"
        )
        return reasoning_completion.choices[0].message.content.split('FINAL LIST')[1].strip()

    def _handle_tool_extraction(self, reasoning_reply: str) -> List[ShoppingListIngredientFirestore]:
        messages = self._create_tool_messages(reasoning_reply)
        json_schema = self._define_ingredients_json_schema()
        tools = self._define_extraction_tools(json_schema)

        completion = self.client.chat.completions.create(
            model="gpt-4-1106-preview",
            messages=messages,
            tools=tools,
            tool_choice={"type": "function",
                         "function": {"name": TOOL_FUNCTION_NAME}}
        )

        reply = completion.choices[0].message.tool_calls[0].function.arguments
        logging.info(f"AI tool extraction completion: {reply}")
        logging.info(
            f"List Combination ToolExtraction Usage: {completion.usage}"
        )
        combined_ingredients = json.loads(reply)['ingredients']
        combined_ingredients = [ShoppingListIngredientExtracted.parse_obj(
            ingredient) for ingredient in combined_ingredients]
        return [convert_to_firestore_ingredient(ingredient) for ingredient in combined_ingredients]

    def _create_tool_messages(self, reasoning_reply: str) -> List[Dict]:
        return [
            {"role": "user", "content": reasoning_reply},
            {"role": "user", "content": TOOL_EXTRACTION_MESSAGE}
        ]

    def _define_ingredients_json_schema(self) -> Dict:
        ingredient_schema = ShoppingListIngredientExtracted.schema()
        logging.info("ING SCHEMA: " + json.dumps(ingredient_schema))
        return {
            "type": "object",
            "properties": {
                "ingredients": {
                    "type": "array",
                    "items": ingredient_schema
                }
            },
            "required": ["ingredients"]
        }

    def _define_extraction_tools(self, json_schema: Dict) -> List[Dict]:
        return [
            {
                "type": "function",
                "function": {
                    "name": TOOL_FUNCTION_NAME,
                    "description": TOOL_FUNCTION_DESCRIPTION,
                    "parameters": json_schema
                }
            }
        ]
