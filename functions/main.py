
from firebase_admin import initialize_app
import logging

from https_on_call.combine_ingredients import combine_ingredients
from https_on_call.extract_recipe_from_images import extract_recipe_from_images
from https_on_call.extract_recipe_from_text import extract_recipe_from_text
from https_on_call.extract_recipe_from_webpage import extract_recipe_from_webpage


# Initialize the Firebase app
initialize_app()

# Initialize logging
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

