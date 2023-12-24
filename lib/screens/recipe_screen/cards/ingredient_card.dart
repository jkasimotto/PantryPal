import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_with_quantity.dart';
import 'package:flutter_recipes/screens/recipe_screen/ingredient_grid.dart';
import 'package:flutter_recipes/screens/recipe_screen/recipe_controller.dart';

class IngredientGridCard extends StatelessWidget {
  final List<IngredientWithQuantity> _ingredients;
  final RecipeController _recipeController;
  final Function(int) _onIngredientSave;

  const IngredientGridCard({
    super.key,
    required List<IngredientWithQuantity> ingredients,
    required RecipeController recipeController,
    required Function(int) onIngredientSave,
    required Function saveRecipe,
  })  : _ingredients = ingredients,
        _recipeController = recipeController,
        _onIngredientSave = onIngredientSave;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.list),
        title: const Text('Ingredients'),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IngredientGrid(
              ingredients: _ingredients,
              nameControllers: _recipeController.ingredientNameControllers,
              quantityControllers:
                  _recipeController.ingredientQuantityControllers,
              unitControllers: _recipeController.ingredientUnitControllers,
              onDelete: (index) {
                _ingredients.removeAt(index);
                _recipeController.ingredientNameControllers.removeAt(index);
                _recipeController.ingredientQuantityControllers.removeAt(index);
                _recipeController.ingredientUnitControllers.removeAt(index);
                Navigator.of(context).pop();
              },
              onSave: _onIngredientSave,
            ),
          ),
        ],
      ),
    );
  }
}
