from typing import List, Optional
import uuid
from pydantic import BaseModel, Field

from model.Quantity import Quantity


class NutritionalInformation(BaseModel):
    calories: float
    fats: float
    carbohydrates: float
    proteins: float
    vitamins: float
    minerals: float


class IngredientMeta(BaseModel):
    iconPath: str = Field('assets/images/icons/food/default.png',
                          description="Path to the ingredient's icon")
    ingredientId: Optional[str] = None


class Ingredient(BaseModel):
    name: str
    form: Optional[str] = Field(
        None, description="The physical form of the ingredient (e.g., whole, sliced, diced)")
    category: Optional[str] = Field(
        None, description="The category to which the ingredient belongs (e.g., vegetable, fruit, dairy)")
    shelfLife: Optional[str] = None
    nutritionalInformation: Optional[NutritionalInformation] = None
    seasonality: Optional[str] = None
    allergens: Optional[List[str]] = None
    substitutions: Optional[List[str]] = None
    meta: IngredientMeta


class IngredientWithQuantity(Ingredient):
    quantity: Quantity


class RecipeMethodStep(BaseModel):
    stepNumber: int
    description: str
    duration: Optional[int] = None
    additionalNotes: Optional[str] = None


class RecipeMetadata(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    ownerId: str
    source: str  # Assuming source is a string representation of the RecipeSource enum
    status: str  # Assuming status is a string representation of the Status enum


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
    meta: RecipeMetadata  # Added meta field