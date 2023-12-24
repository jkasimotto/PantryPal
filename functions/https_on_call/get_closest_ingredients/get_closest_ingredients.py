
import asyncio
import json
import logging
from typing import Dict, List

import numpy as np
from firebase_admin import firestore, initialize_app
from openai import OpenAI
from sklearn.metrics.pairwise import cosine_similarity

def get_all_ingredient_embeddings():
    db = firestore.client()
    # Change this to your actual collection name
    embeddings_ref = db.collection('ingredient_embeddings')

    docs = embeddings_ref.stream()

    embeddings = []
    for doc in docs:
        embeddings.append(doc.to_dict())

    return embeddings


def convert_texts_to_embeddings(texts: List[str]) -> List[List[float]]:
    client = OpenAI()
    embeddings = []

    for text in texts:
        response = client.embeddings.create(
            model="text-embedding-ada-002",
            input=text,
            encoding_format="float"
        )
        embeddings.append(response['data'][0]['embedding'])

    return embeddings


def find_closest_embeddings(search_embeddings: List[List[float]], all_embeddings: List[List[float]], k: int) -> List[List[int]]:
    # Convert the lists to numpy arrays
    search_embeddings = np.array(search_embeddings)
    all_embeddings = np.array(all_embeddings)

    # Calculate the cosine similarity between the search embeddings and all embeddings
    similarity_matrix = cosine_similarity(search_embeddings, all_embeddings)

    # Get the indices of the top k embeddings for each search embedding
    top_k_indices = np.argpartition(similarity_matrix, -k, axis=1)[:, -k:]

    return top_k_indices.tolist()

