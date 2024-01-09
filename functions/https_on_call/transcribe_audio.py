import base64
import io
import logging
import time

from firebase_functions import https_fn
from openai import OpenAI

from util.logging import log_performance


@https_fn.on_call(secrets=['OPENAI_API_KEY'])
def transcribe_audio(req: https_fn.CallableRequest):
    start_time = time.time()
    try:
        logging.info(
            f"Received transcription request at {time.ctime(start_time)}")
        # Create the OpenAI client
        client = OpenAI()

        # Extract the base64 encoded audio bytes from the data
        audio_base64 = req.data['audio']

        # Decode the base64 bytes
        audio_bytes = base64.b64decode(audio_base64)

        # Create a BytesIO object from the audio bytes
        audio_file = io.BytesIO(audio_bytes)
        audio_file.name = 'audio.m4a'

        audio_size = len(audio_bytes)
        logging.info(f"Audio size: {audio_size} bytes")

        # Transcribe the audio using the OpenAI Whisper API
        transcript = client.audio.transcriptions.create(
            model="whisper-1",
            file=audio_file,
        )

        log_performance(start_time, "Audio transcription")
        return {'status': 'success', 'transcript': transcript.text}
    except Exception as e:
        logging.error('Error during transcription: %s', str(e))
        log_performance(start_time, "Failed audio transcription")
        return {'status': 'error', 'error': str(e)}