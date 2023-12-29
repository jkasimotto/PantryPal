# Location Enum for Shopping List


from enum import Enum

from pydantic import BaseModel, Field
from typing import List, Optional
from model.extraction.quantity import Quantity


from model.extraction.recipe import IngredientWithQuantity


class Location(Enum):
    Produce = "Produce"
    Meat_Seafood = "Meat & Seafood"
    Dairy = "Dairy"
    Frozen_Foods = "Frozen Foods"
    Aisle = "Aisle"


class ShoppingListIngredient(BaseModel):
    quantity: float
    units: str
    name: str
    form: Optional[str] = Field(
        None, description="The physical form of the ingredient (e.g., whole, sliced, diced)")
    category: str = Field(
        ..., description="The category to which the ingredient belongs (e.g., vegetable, fruit, dairy)")
    location: Location = Field(
        ..., description="The location in the grocery store where the ingredient can be found. "
        "Possible values: " + ", ".join([item.value for item in Location]))


class ShoppingList(BaseModel):
    recipe_titles: List[str]
    ingredients: List[ShoppingListIngredient]
