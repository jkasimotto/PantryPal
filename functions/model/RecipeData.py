from enum import Enum
from typing import List, Optional

from model.RecipeMethodStepData import RecipeMethodStepData
from model.IngredientData import IngredientData  # Import IngredientData
from pydantic import BaseModel


class RecipeData(BaseModel):
    title: str
    ingredients: List[IngredientData]
    method: List[RecipeMethodStepData]
    cuisine: str  # The style or origin of the cooking
    course: str  # The type of meal or course the recipe is intended for
    servings: int  # The number of servings or people the recipe is intended to feed
    prepTime: int  # The duration of time required for preparation
    cookTime: int  # The duration of time required for cooking
    # Additional information such as tips, variations, or serving suggestions
    notes: Optional[str]
