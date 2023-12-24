import logging
import os
import time
from typing import Dict

from firebase_functions import https_fn

from extract_recipe import extract_recipe
from util.logging import log_performance


@https_fn.on_call(secrets=["OPENAI_API_KEY"], timeout_sec=540)
def extract_recipe_from_text(req: https_fn.CallableRequest) -> Dict:
    # Authentication / user information is automatically added to the request.
    # logging.info(f"User ID: {req.auth.uid}")
    # logging.info(f"User Name: {req.auth.token.get('name', '')}")
    # logging.info(f"User Picture: {req.auth.token.get('picture', '')}")
    # logging.info(f"User Email: {req.auth.token.get('email', '')}")

    start_time = time.time()
    try:
        logging.info(
            f"Received recipe extraction request at {time.ctime(start_time)}")

        # Extract the text from the request data
        text = req.data['text']
        logging.debug(f"Extracted text from request: {text}")

        openai_api_key = os.environ.get('OPENAI_API_KEY')
        logging.debug(f"Retrieved OpenAI API key from environment: {openai_api_key}")

        # Call the extract_recipe_from_text function
        logging.info("Calling extract_recipe function...")
        result = extract_recipe(text, openai_api_key)
        logging.debug(f"Result from extract_recipe function: {result}")
        logging.info("Successfully extracted recipe.")

        log_performance(start_time, "Recipe extraction")
        return result
    except Exception as e:
        logging.error('Error during recipe extraction: %s', str(e))
        log_performance(start_time, "Failed recipe extraction")
        return {'status': 'error', 'error': str(e)}