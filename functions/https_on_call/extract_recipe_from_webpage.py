import logging
import os
import time
from typing import Dict

from util.web import scrape_webpage
from bs4 import BeautifulSoup
from extract_recipe import extract_recipe
from firebase_functions import https_fn
from util.logging import log_performance


@https_fn.on_call(secrets=["OPENAI_API_KEY"], timeout_sec=300)
def extract_recipe_from_webpage(req: https_fn.CallableRequest) -> Dict:
    start_time = time.time()

    # Authentication / user information is automatically added to the request.
    logging.info(f"User ID: {req.auth.uid}")
    logging.info(f"User Name: {req.auth.token.get('name', '')}")
    logging.info(f"User Picture: {req.auth.token.get('picture', '')}")
    logging.info(f"User Email: {req.auth.token.get('email', '')}")

    logging.info(
        f"Starting to extract recipe from webpage at {time.ctime(start_time)}")

    # Extract URL from the request
    url = req.data['url']
    logging.debug(f"URL extracted from request: {url}")

    openai_api_key = os.environ.get('OPENAI_API_KEY')
    logging.debug(f"OpenAI API key retrieved from environment: {openai_api_key}")

    try:
        # Scrape the webpage
        logging.info(f"Scraping webpage: {url}")
        scrape_result = scrape_webpage(url)
        logging.debug(f"Scrape result: {scrape_result}")

        # Check if the scraping was successful
        if scrape_result['status'] != 'success':
            logging.error(f"Failed to scrape webpage: {url}")
            return {'status': 'error', 'error': scrape_result['message']}

        # Extract the text from the webpage content
        logging.info(f"Extracting text from webpage content")
        soup = BeautifulSoup(scrape_result['content'], 'html.parser')
        text = soup.get_text()
        logging.debug(f"Extracted text from webpage content: {text}")

        # Extract a recipe from the text
        logging.info(f"Extracting recipe from text")
        recipe_result = extract_recipe(text, openai_api_key)
        logging.debug(f"Recipe result: {recipe_result}")

        log_performance(start_time, "Recipe extraction from webpage")
        return recipe_result
    except Exception as e:
        logging.error(f"Error during recipe extraction from webpage: {str(e)}")
        log_performance(start_time, "Failed recipe extraction from webpage")
        return {'status': 'error', 'error': str(e)}