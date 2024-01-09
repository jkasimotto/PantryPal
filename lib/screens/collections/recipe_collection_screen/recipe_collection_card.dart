import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/models/status.dart';
import 'package:flutter_recipes/shared/progress/loading_recipe_card.dart';
import 'package:flutter_recipes/screens/collections/recipe_collection_screen/recipe_collection_card_error.dart';
import 'package:flutter_recipes/screens/collections/recipe_collection_screen/recipe_collection_card_success.dart';

class RecipeCollectionCard extends StatelessWidget {
  final RecipeModel recipe;
  final int index;

  const RecipeCollectionCard(
      {super.key, required this.recipe, required this.index});

  @override
  Widget build(BuildContext context) {
    return _buildCardByStatus(context, recipe.meta.status);
  }

  Widget _buildCardByStatus(BuildContext context, Status status) {
    switch (status) {
      case Status.loading:
        return LoadingRecipeCard(recipe: recipe);
      case Status.success:
        return RecipeCollectionSuccessCard(recipe: recipe, index: index);
      case Status.error:
        return RecipeCollectionErrorCard(recipe: recipe);
      default:
        return Container(); // Or some other placeholder for unexpected status
    }
  }
}
