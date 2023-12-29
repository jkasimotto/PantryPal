import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe.dart';
import 'package:flutter_recipes/models/status.dart';
import 'package:flutter_recipes/screens/home_screen/loading_recipe_card.dart';
import 'package:flutter_recipes/screens/recipe_collection_screen.dart/recipe_collection_card/recipe_collection_error_card.dart';
import 'package:flutter_recipes/screens/recipe_collection_screen.dart/recipe_collection_card/recipe_collection_success_card.dart';

class RecipeCollectionCard extends StatelessWidget {
  final Recipe recipe;
  final Function(bool?) onChanged;

  const RecipeCollectionCard({
    super.key,
    required this.recipe,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCardByStatus(context, recipe.meta.status);
  }

  Widget _buildCardByStatus(BuildContext context, Status status) {
    switch (status) {
      case Status.loading:
        return LoadingRecipeCard(recipe: recipe);
      case Status.success:
        return RecipeCollectionSuccessCard(
            recipe: recipe, onChanged: onChanged);
      case Status.error:
        return RecipeCollectionErrorCard(recipe: recipe);
      default:
        return Container(); // Or some other placeholder for unexpected status
    }
  }
}