from typing import List, Optional
import uuid
from pydantic import BaseModel, Field

from model.extraction.quantity import Quantity


class NutritionalInformation(BaseModel):
    calories: float
    fats: float
    carbohydrates: float
    proteins: float
    vitamins: float
    minerals: float


class IngredientWithQuantity(BaseModel):
    quantity: Quantity
    name: str
    form: Optional[str] = Field(
        None, description="The physical form of the ingredient (e.g., whole, sliced, diced)")
    category: str = Field(
        ..., description="The category to which the ingredient belongs (e.g., vegetable, fruit, dairy)")
    shelfLife: str
    nutritionalInformation: Optional[NutritionalInformation] = None
    seasonality: Optional[str] = None
    allergens: Optional[List[str]] = None
    substitutions: Optional[List[str]] = None


class RecipeMethodStep(BaseModel):
    stepNumber: int
    description: str
    duration: Optional[int] = None
    additionalNotes: Optional[str] = None


class Recipe(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    title: str
    ingredients: List[IngredientWithQuantity]
    method: List[RecipeMethodStep]
    cuisine: str
    course: str
    servings: int
    prepTime: int
    cookTime: int
    notes: Optional[str]