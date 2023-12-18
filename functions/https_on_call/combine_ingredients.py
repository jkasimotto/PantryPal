import json
import logging
import time
from typing import Dict

from firebase_functions import https_fn
from openai import OpenAI

from util.logging import log_performance


@https_fn.on_call(secrets=["OPENAI_API_KEY"], timeout_sec=120)
def combine_ingredients(req: https_fn.CallableRequest) -> Dict:
    start_time = time.time()
    try:
        logging.info(
            f"Received ingredient combination request at {time.ctime(start_time)}")

        # Extract the recipes from the request data
        recipes = req.data['recipes']

        # Extract only the name and quantity from each ingredient in each recipe
        nested_ingredients = [(ingredient['name'], ingredient['quantity'])
                              for recipe in recipes for ingredient in recipe['data']['ingredients']]

        # Flatten the list of ingredients
        ingredients = [{'name': name, 'quantity': quantity}
                       for name, quantity in nested_ingredients]

        # Initialize the openai client
        client = OpenAI()

        # Convert the ingredients to a string
        ingredients_text = ', '.join([f"{ingredient['name']}: {ingredient['quantity']}" for ingredient in ingredients])

        # Define the message for the reasoning call
        reasoning_message = {
            "role": "user",
            "content": f"1. Think step by step.\n2. Group ingredients that should be combined into one. (e.g. carrots and carrot but not tomatos and cherry tomatos)\n3. For each group go through and convert the units into one sensible unit and then sum their amounts. Here are the ingredients: {ingredients_text}"
        }

        # Send the reasoning call to the OpenAI API
        reasoning_completion = client.chat.completions.create(
            model="gpt-4-1106-preview",
            messages=[reasoning_message]
        )

        # Extract the assistant's reply
        reasoning_reply = reasoning_completion.choices[0].message.content

        # Pass the reasoning reply as a message to the tool call
        tool_message = {
            "role": "user",
            "content": reasoning_reply
        }

        # Update the messages list
        messages = [tool_message]

        # Define the JSON schema for the expected output
        json_schema = {
            "type": "object",
            "properties": {
                "ingredients": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "ingredient": {"type": "string"},
                            "quantity": {"type": "string"},
                            "category": {
                                "type": "string",
                                "enum": ["produce", "fridge", "freezer", "aisle"]
                            },
                        },
                        "required": ["ingredient", "quantity", "category"]
                    }
                }
            },
            "required": ["ingredients"]
        }

        # Define the function
        tools = [
            {
                "type": "function",
                "function": {
                    "name": "combine_ingredients",
                    "description": "Combine ingredients from multiple recipes",
                    "parameters": json_schema
                }
            }
        ]

        # Send the request to the OpenAI API
        completion = client.chat.completions.create(
            model="gpt-4-1106-preview",
            messages=messages,
            tools=tools,
            tool_choice={"type": "function", "function": {
                "name": "combine_ingredients"}}
        )

        # Extract the assistant's reply
        reply = completion.choices[0].message.tool_calls[0].function.arguments

        # Parse the reply into JSON
        combined_ingredients = json.loads(reply)

        # Get the list of the ingredients
        combined_ingredients = combined_ingredients['ingredients']

        logging.info(f"Combined Ingredients: {combined_ingredients}")

        # Organize the ingredients by category
        organized_ingredients = {
            "produce": [],
            "fridge": [],
            "freezer": [],
            "aisle": []
        }
        for ingredient in combined_ingredients:
            organized_ingredients[ingredient['category']].append(ingredient)

        log_performance(start_time, "Ingredient combination")
        return {'status': 'success', 'combined_ingredients': organized_ingredients}
    except Exception as e:
        logging.error('Error during ingredient combination: %s', str(e))
        log_performance(start_time, "Failed ingredient combination")
        return {'status': 'error', 'error': str(e)}
