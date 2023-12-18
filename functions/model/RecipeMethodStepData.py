from pydantic import BaseModel, Field

class RecipeMethodStepData(BaseModel):
    stepNumber: int = Field(..., gt=0, description="The order of the method step")
    description: str = Field(..., min_length=10, description="Detailed description of the step")
    duration: int = Field(None, gt=0, description="Duration in minutes for this step (optional)")
    additionalNotes: str = Field(None, description="Additional notes or tips (optional)")

