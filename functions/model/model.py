from typing import List, Optional
from pydantic import BaseModel, Field
import uuid
from datetime import datetime
from enum import Enum

# Nutritional Information  Model


class NutritionalInformation(BaseModel):
    calories: float
    fats: float
    carbohydrates: float
    proteins: float
    vitamins: float
    minerals: float

# Ingredient  Model


class Ingredient(BaseModel):
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

# Quantity  Model


class IngredientWithQuantity(BaseModel):
    ingredientData: Ingredient
    quantity: float = Field(...,
                            description="The numerical amount of the ingredient")
    units: str = Field(..., description="The unit of measurement for the quantity (e.g., grams, cups, teaspoons)")

# Recipe Method Step  Model


class RecipeMethodStep(BaseModel):
    stepNumber: int
    description: str
    duration: Optional[int] = None
    additionalNotes: Optional[str] = None

# Recipe  Model


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

# Location Enum for Shopping List


class Location(str, Enum):
    Produce = "Produce"
    Meat_Seafood = "Meat & Seafood"
    Dairy = "Dairy"
    Frozen_Foods = "Frozen Foods"
    Aisle = "Aisle"

# Shopping List Ingredient  Model


class ShoppingListIngredient(BaseModel):
    # Combined Ingredient and Quantity
    ingredientName: str
    ingredientForm: str
    ingredientCategory: str
    quantity: float = Field(...,
                            description="The numerical amount of the ingredient")
    units: str = Field(..., description="The unit of measurement for the quantity (e.g., grams, cups, teaspoons)")
    location: Location = Field(default=Location.Aisle)

# Shopping List  Model


class ShoppingList(BaseModel):
    recipe_titles: List[str]
    ingredients: List[ShoppingListIngredient]
