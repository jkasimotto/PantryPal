
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


def is_ingredient_in_list(ingredient: str, ingredient_list: List[str]) -> int:
    client = OpenAI()

    # Convert the list of ingredients to a string
    ingredient_list_str = '\n'.join(f"{i}: {ingredient}" for i, ingredient in enumerate(ingredient_list))

    # Define the JSON schema for the expected output
    json_schema = {
        "index": "integer"
    }

    # Define the message
    messages = [
        {
            "role": "user",
            "content": f"Is '{ingredient}' in {ingredient_list_str}. If it matches, return its index. If it is not, return -1. Use the json format {json_schema}"
        },
    ]

    # Send the request to the OpenAI API
    completion = client.chat.completions.create(
        model="gpt-4-1106-preview",
        messages=messages,
        response_format={ "type": "json_object" },
    )

    # Extract the assistant's reply
    reply = completion.choices[0].message.content

    # Parse the reply into JSON
    index = json.loads(reply)

    # If the ingredient is not in the list, return a negative index
    if index == -1:
        return -len(ingredient_list) - 1
    
    return index


async def get_closest_existing_ingredients(ingredients: List[str]) -> Dict[str, List[str]]:
    # Get all ingredient embeddings from Firestore
    all_ingredients = get_all_ingredient_embeddings()
    existing_ingredients = [ingredient['name'] for ingredient in all_ingredients]
    existing_embeddings = [ingredient['embedding'] for ingredient in all_ingredients]

    # Calculate new embeddings for the new ingredients
    new_embeddings = convert_texts_to_embeddings(ingredients)

    # Find the closest 3 existing ingredients for each new ingredient
    closest_indices = find_closest_embeddings(new_embeddings, existing_embeddings, 3)

    # Create a dictionary to store the closest existing ingredients for each new ingredient
    closest_existing_ingredients = {}

    # For each new ingredient, check if it is in the list of closest existing ingredients
    tasks = []
    for ingredient, indices in zip(ingredients, closest_indices):
        closest_ingredients = [existing_ingredients[i] for i in indices]
        tasks.append(is_ingredient_in_list(ingredient, closest_ingredients))

    results = await asyncio.gather(*tasks)

    for ingredient, result, new_embedding in zip(ingredients, results, new_embeddings):
        if result < 0:
            # If the ingredient is not in the list of closest ingredients, create a new embedding
            all_ingredients.append({'name': ingredient, 'embedding': new_embedding.tolist()})
            existing_ingredients.append(ingredient)
            existing_embeddings.append(new_embedding.tolist())
            closest_existing_ingredients[ingredient] = [ingredient]
        else:
            closest_existing_ingredients[ingredient] = existing_ingredients[result]

    return closest_existing_ingredients