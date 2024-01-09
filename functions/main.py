
from firebase_admin import initialize_app
import logging

from https_on_call.combine_ingredients import combine_ingredients
from https_on_call.extract_recipe_from_images import extract_recipe_from_images
from https_on_call.extract_recipe_from_text import extract_recipe_from_text
from https_on_call.extract_recipe_from_webpage import extract_recipe_from_webpage
from https_on_call.add_ingredient_icon_path import add_ingredient_icon_path_to_entity, list_file_names
from https_on_call.get_ingredient_metadata import get_ingredient_metadata_by_exact_name_match
from https_on_call.transcribe_audio import transcribe_audio


# Initialize the Firebase app
initialize_app()

# Initialize logging
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')


