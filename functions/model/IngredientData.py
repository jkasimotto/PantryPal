from typing import List, Optional
from pydantic import BaseModel, Field


class QuantityData(BaseModel):
    value: float  # Numeric value representing the quantity of the ingredient
    units: Optional[str] = Field(
        None, description="Optional unit of measurement for the quantity. Should be provided if required and not inherent to the item itself.")


class NutritionalInformation(BaseModel):
    calories: float  # Caloric content
    fats: float  # Fat content
    carbohydrates: float  # Carbohydrate content
    proteins: float  # Protein content
    vitamins: float  # Vitamin content
    minerals: float  # Mineral content


class IngredientData(BaseModel):
    name: str  # Name of the ingredient
    quantity: QuantityData  # Quantity of the ingredient needed
    form: str  # Form of the ingredient (e.g., "diced", "crushed")
    category: str  # Category of the ingredient (e.g., "Vegetable", "Fruit")
    # List of allergens contained in the ingredient
    allergens: Optional[List[str]] = None
    # List of possible substitutions for the ingredient
    substitutions: Optional[List[str]] = None
    # Nutritional details of the ingredient
    nutritionalInformation: NutritionalInformation
    shelfLife: str  # Expected shelf life of the ingredient
    # Season(s) in which the ingredient is typically available
    seasonality: Optional[str] = None
