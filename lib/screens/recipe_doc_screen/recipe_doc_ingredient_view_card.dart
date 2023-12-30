import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_model.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/screens/recipe_doc_screen/recipe_doc_ingredient_view.dart';
import 'package:flutter_recipes/screens/recipe_screen/recipe_controller.dart';

class RecipeDocIngredientViewCard extends StatefulWidget {
  final RecipeModel recipe;
  final RecipeController _recipeController;

  const RecipeDocIngredientViewCard({
    super.key,
    required this.recipe,
    required RecipeController recipeController,
    required Function saveRecipe,
  }) : _recipeController = recipeController;

  @override
  // ignore: library_private_types_in_public_api
  _RecipeDocIngredientViewCardState createState() =>
      _RecipeDocIngredientViewCardState();
}

class _RecipeDocIngredientViewCardState
    extends State<RecipeDocIngredientViewCard> {
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
            child: RecipeDocIngredientView(
              recipe: widget.recipe,
              recipeController: widget._recipeController,
              currentView: _currentView,
            ),
          ),
        ],
      ),
    );
  }
}
