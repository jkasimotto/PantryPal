import logging
import time


def log_performance(start_time, operation):
    elapsed_time = time.time() - start_time
    logging.info(f"{operation} completed in {elapsed_time:.2f} seconds")