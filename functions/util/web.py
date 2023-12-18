import logging
from typing import Dict

import requests
import robotexclusionrulesparser 
from bs4 import BeautifulSoup


def scrape_webpage(url: str) -> Dict:
    logging.info(f"Starting to scrape webpage: {url}")

    # Check if the URL starts with http:// or https://
    if not url.startswith(('http://', 'https://')):
        url = 'http://' + url
    robots_url = "/".join(url.split("/")[:3]) + "/robots.txt"
    robots_parser = robotexclusionrulesparser.RobotFileParserLookalike()
    robots_parser.set_url(robots_url)
    robots_parser.read()

    # Check if the webpage can be scraped
    if not robots_parser.can_fetch("*", url):
        logging.error(
            f"Webpage {url} cannot be scraped as per the website's robots.txt file.")
        return {'status': 'error', 'message': "This webpage cannot be scraped as per the website's robots.txt file."}

    logging.info(f"Sending GET request to {url}")
    # Send a GET request to the webpage
    response = requests.get(url)

    # Check if the request was successful
    if response.status_code != 200:
        logging.error(
            f"Failed to retrieve webpage. Status code: {response.status_code}")
        return {'status': 'error', 'message': f"Failed to retrieve webpage. Status code: {response.status_code}"}

    logging.info(f"Successfully retrieved webpage: {url}")
    # Parse the webpage content
    soup = BeautifulSoup(response.content, 'html.parser')

    logging.debug(f"Parsed content from {url}: {str(soup)}")
    # Return the parsed content as a string
    return {'status': 'success', 'content': str(soup)}