
import google.cloud.firestore
from firebase_admin import firestore
from firebase_functions import https_fn
from model.firestore.recipe import IngredientMeta


@https_fn.on_call(timeout_sec=120)
def get_ingredient_metadata_by_exact_name_match(req: https_fn.CallableRequest):
    ingredient_name = req.data.get('ingredient_name')
    if not ingredient_name:
        return {'status': 'error', 'error': 'No ingredient name provided'}

    db = firestore.Client()
    ingredients_ref = db.collection('ingredients')
    query = ingredients_ref.where('name', '==', ingredient_name.lower()).limit(1)
    docs = query.stream()

    for doc in docs:
        ingredient = doc.to_dict()
        ingredient_meta = IngredientMeta(**ingredient)
        return {'status': 'success', 'ingredientMeta': ingredient_meta.dict()}

    return {'status': 'success', 'ingredientMeta': IngredientMeta().dict()}