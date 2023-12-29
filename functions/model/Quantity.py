from pydantic import BaseModel, Field


class Quantity(BaseModel):
    amount: float = Field(...,
                          description="The numerical amount of the ingredient")
    units: str = Field(..., description="The unit of measurement for the quantity (e.g., grams, cups, teaspoons)")