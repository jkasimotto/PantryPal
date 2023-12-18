import logging
import time
from typing import Dict

from firebase_functions import https_fn
from openai import OpenAI

from util.logging import log_performance


@https_fn.on_call(secrets=["OPENAI_API_KEY"], timeout_sec=300)
def extract_recipe_from_images(req: https_fn.CallableRequest) -> Dict:
    start_time = time.time()
    try:
        logging.info(
            f"Received recipe extraction request from images at {time.ctime(start_time)}")

        # Extract the base64 encoded images from the request data
        base64_images = req.data['images']
        logging.debug(f"Extracted base64 images from request: {len(base64_images)} images")

        # Initialize the openai client
        client = OpenAI()

        # Prepare the content for the API call
        content = [
            {
                "type": "text",
                "text": """
                1. If the image shows text, extract the text. 
                2. If the image shows food, list all the food and amounts of food that you can see.
                """
            },
        ] + [
            {
                "type": "image_url",
                "image_url": {
                    "url": f"data:image/jpeg;base64,{base64_image}",
                    "detail": "high"
                }
            } for base64_image in base64_images
        ]

        logging.debug(f"Prepared content for API call: {len(content)} items")

        # Prepare the message for the API call
        message = {
            "role": "user",
            "content": content
        }

        logging.debug(f"Prepared message for API call: {message}")

        # Send the request to the OpenAI API
        response = client.chat.completions.create(
            model="gpt-4-vision-preview",
            messages=[message],
            max_tokens=2000,
        )

        logging.debug(f"Received response from OpenAI API: {response}")

        # Extract the assistant's replies
        replies = [choice.message.content for choice in response.choices]

        # Concatenate the replies into a single string
        text = ' '.join(replies)
        logging.info(f"Text extracted from image: {text}")

        log_performance(start_time, "Recipe extraction from images")
        return {'status': 'success', 'text': text}
    except Exception as e:
        logging.error('Error during recipe extraction from images: %s', str(e))
        log_performance(start_time, "Failed recipe extraction from images")
        return {'status': 'error', 'error': str(e)}