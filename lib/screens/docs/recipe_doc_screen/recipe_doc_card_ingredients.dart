import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_ingredient_view.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_controller.dart';

class RecipeDocCardIngredients extends StatefulWidget {
  final RecipeModel recipe;
  final RecipeDocController _recipeController;

  const RecipeDocCardIngredients({
    super.key,
    required this.recipe,
    required RecipeDocController recipeController,
    required Function saveRecipe,
  }) : _recipeController = recipeController;

  @override
  // ignore: library_private_types_in_public_api
  _RecipeDocCardIngredientsState createState() =>
      _RecipeDocCardIngredientsState();
}

class _RecipeDocCardIngredientsState extends State<RecipeDocCardIngredients> {
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
        // trailing: IconButton(
        //   icon: const Icon(Icons.view_headline), // choose an appropriate icon
        //   onPressed: _toggleView,
        // ),
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
