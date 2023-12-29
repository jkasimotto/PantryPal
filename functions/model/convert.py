from model.Quantity import Quantity
from model.extraction.shopping_list import ShoppingListIngredient as ShoppingListIngredientExtraction
from model.firestore.shopping_list import ShoppingListIngredient as ShoppingListIngredientFirestore
from model.firestore.shopping_list import Location
from model.firestore.recipe import IngredientMeta


def convert_to_firestore_ingredient(extracted_ingredient: ShoppingListIngredientExtraction) -> ShoppingListIngredientFirestore:
    # Create a new instance of the Firestore ShoppingListIngredient
    firestore_ingredient = ShoppingListIngredientFirestore(
        name=extracted_ingredient.name,
        # We define the extracted model in a flattened structure because:
        # 1. It's less tokens in the chat completion
        # 2. OpenAI function completion doesn't always get nested models correct.
        quantity=Quantity( 
            amount=extracted_ingredient.quantity,
            units=extracted_ingredient.units
        ),
        location=extracted_ingredient.location,
        meta=IngredientMeta(
            iconPath='',
            ingredientId=''
        )

    )

    return firestore_ingredient
