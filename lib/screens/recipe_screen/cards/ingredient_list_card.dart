import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/ingredient/ingredient.dart';
import 'package:flutter_recipes/screens/recipe_screen/ingredient_view.dart';
import 'package:flutter_recipes/screens/recipe_screen/recipe_controller.dart';

class RecipeDocIngredientListCard extends StatefulWidget {
  final List<IngredientWithQuantity> _ingredients;
  final RecipeController _recipeController;
  final Function(int) _onIngredientSave;

  const RecipeDocIngredientListCard({
    super.key,
    required List<IngredientWithQuantity> ingredients,
    required RecipeController recipeController,
    required Function(int) onIngredientSave,
    required Function saveRecipe,
  })  : _ingredients = ingredients,
        _recipeController = recipeController,
        _onIngredientSave = onIngredientSave;

  @override
  _RecipeDocIngredientListCardState createState() =>
      _RecipeDocIngredientListCardState();
}

class _RecipeDocIngredientListCardState
    extends State<RecipeDocIngredientListCard> {
  CurrentView _currentView = CurrentView.grid;

  void _toggleView() {
    setState(() {
      _currentView = CurrentView
          .values[(_currentView.index + 1) % CurrentView.values.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.list),
        title: const Text('Ingredients'),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IngredientView(
              ingredients: widget._ingredients,
              nameControllers:
                  widget._recipeController.ingredientNameControllers,
              quantityControllers:
                  widget._recipeController.ingredientQuantityControllers,
              unitControllers:
                  widget._recipeController.ingredientUnitControllers,
              onDelete: (index) {
                widget._ingredients.removeAt(index);
                widget._recipeController.ingredientNameControllers
                    .removeAt(index);
                widget._recipeController.ingredientQuantityControllers
                    .removeAt(index);
                widget._recipeController.ingredientUnitControllers
                    .removeAt(index);
                Navigator.of(context).pop();
              },
              onSave: widget._onIngredientSave,
              currentView: _currentView,
            ),
          ),
        ],
      ),
    );
  }
}
