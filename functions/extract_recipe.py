import json
import logging
import time
from typing import Dict

from model.model import Recipe
from util.logging import log_performance


def extract_recipe(text: str, openai_api_key: str) -> Dict:
    from openai import OpenAI

    start_time = time.time()
    try:
        logging.info("Initializing OpenAI client...")
        client = OpenAI(api_key=openai_api_key)

        logging.debug("Defining JSON schema for expected output...")
        json_schema = Recipe.schema()  # Use Pydantic's schema method
        logging.info(f"JSON schema: {json_schema}")

        logging.debug("Defining function and message for OpenAI API request...")
        tools = [
            {
                "type": "function",
                "function": {
                    "name": "extract_recipe_from_text",
                    "description": "Extract recipe details from text",
                    "parameters": json_schema
                }
            }
        ]

        messages = [
            {
                "role": "user",
                "content": f"Extract the recipe details from the following text: {text}"
            }
        ]

        logging.debug(f"Tools: {tools}")
        logging.debug(f"Messages: {messages}")

        logging.info("Sending request to OpenAI API...")
        completion = client.chat.completions.create(
            model="gpt-4-1106-preview",
            messages=messages,
            tools=tools,
            tool_choice={"type": "function", "function": {
                "name": "extract_recipe_from_text"}}
        )

        logging.debug("Extracting assistant's reply from API response...")
        reply = completion.choices[0].message.tool_calls[0].function.arguments
        logging.info(f"Reply: {reply}")

        logging.debug("Parsing reply into JSON...")
        recipe_data = json.loads(reply)
        logging.debug(f"Recipe data: {recipe_data}")

        log_performance(start_time, "Recipe extraction from text")
        logging.info("Recipe extraction successful.")
        return {'status': 'success', 'recipe': recipe_data}
    except Exception as e:
        logging.error('Error during recipe extraction from text: %s', str(e))
        log_performance(start_time, "Failed recipe extraction from text")
        return {'status': 'error', 'error': str(e)}