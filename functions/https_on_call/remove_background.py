import base64
import logging
import time
from firebase_functions import https_fn
from rembg import remove
from util.logging import log_performance

@https_fn.on_request(timeout_sec=540)
def remove_background_from_image(req: https_fn.Request) -> https_fn.Response:
    """
    Receive an image via HTTP request and remove its background using the rembg library.
    The image should be provided as a base64-encoded string in the 'image' parameter.
    """
    start_time = time.time()
    try:
        # Extract the image from the request data
        image_data = req.args.get('image')
        if image_data is None:
            return https_fn.Response("No image parameter provided", status=400)
        
        logging.info("Calling remove function from rembg library...")
        result_image = remove(base64.b64decode(image_data))
        logging.info("Successfully removed background from image.")

        log_performance(start_time, "Background removal")

        # Convert the result image to a suitable format for return, e.g., base64
        result_image_base64 = base64.b64encode(result_image).decode('utf-8')
        return https_fn.Response({
            'status': 'success',
            'image': result_image_base64
        }, status=200, headers={'Content-Type': 'application/json'})
    except Exception as e:
        logging.error('Error during background removal: %s', str(e))
        log_performance(start_time, "Failed background removal")
        return https_fn.Response({
            'status': 'error',
            'error': str(e)
        }, status=500, headers={'Content-Type': 'application/json'})