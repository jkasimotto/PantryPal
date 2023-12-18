import logging
import os
import time

import replicate
from firebase_functions import https_fn

from functions.util.logging import log_performance


@https_fn.on_call(secrets=["OPENAI_API_KEY", "REPLICATE_API_TOKEN"], timeout_sec=180)
def transcribe_youtube_video(req: https_fn.CallableRequest):
    start_time = time.time()
    try:
        logging.info(
            f"Received YouTube transcription request at {time.ctime(start_time)}")

        # Download the YouTube video
        youtube = YouTube(req.data['url'])
        audio_stream = youtube.streams.filter(only_audio=True).first()
        # Ensure the downloaded file is in wav format
        audio_file_path = audio_stream.download(
            filename="audio", skip_existing=False)

        # Check the size of the WAV file
        file_size = os.path.getsize(audio_file_path)
        logging.info(f"Downloaded audio file size: {file_size} bytes")

        # Use incredibly fast whisper transcription
        logging.info(f"Sending audio file to replicate whisper api")
        output = replicate.run(
            # "vaibhavs10/incredibly-fast-whisper:37dfc0d6a7eb43ff84e230f74a24dab84e6bb7756c9b457dbdcceca3de7a4a04",
            "vaibhavs10/incredibly-fast-whisper:37dfc0d6a7eb43ff84e230f74a24dab84e6bb7756c9b457dbdcceca3de7a4a04",
            # "openai/whisper:4d50797290df275329f202e48c76360b3f22b08d28c196cbc54600319435f8d2",
            input={"audio": open(audio_file_path, "rb"), "language": "English"}
        )

        full_transcript = output['text']
        logging.info(f"Received transcription {full_transcript}")

        log_performance(start_time, "YouTube video transcription")
        return {'status': 'success', 'transcript': full_transcript}
    except Exception as e:
        logging.error('Error during YouTube video transcription: %s', str(e))
        log_performance(start_time, "Failed YouTube video transcription")
        return {'status': 'error', 'error': str(e)}