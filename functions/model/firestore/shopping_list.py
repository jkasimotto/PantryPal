from enum import Enum


from pydantic import BaseModel


from typing import List

from model.firestore.recipe import IngredientWithQuantity


class Location(str, Enum):
    Produce = "Produce"
    Meat_Seafood = "Meat & Seafood"
    Dairy = "Dairy"
    Frozen_Foods = "Frozen Foods"
    Aisle = "Aisle"


class ShoppingListIngredient(IngredientWithQuantity):
    location: Location


class ShoppingList(BaseModel):
    id: str
    recipeTitles: List[str]
    ingredients: List[ShoppingListIngredient]


# Location Enum for Shopping List
