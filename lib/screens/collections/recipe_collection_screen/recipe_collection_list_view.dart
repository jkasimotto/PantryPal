import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_filter_provider.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_provider.dart';
import 'package:flutter_recipes/screens/collections/recipe_collection_screen/recipe_collection_card.dart';
import 'package:provider/provider.dart';

class RecipeCollectionListView extends StatelessWidget {
  const RecipeCollectionListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    return Consumer<RecipeFilterProvider>(
      builder: (context, recipeFilterProvider, child) {
        return ValueListenableBuilder<List<RecipeModel>>(
          valueListenable: recipeProvider.recipes,
          builder: (context, recipes, child) {
            List<RecipeModel> filteredRecipes =
                recipeFilterProvider.filterRecipes(recipes);

            return ListView.builder(
              itemCount: filteredRecipes.length,
              itemBuilder: (context, index) {
                RecipeModel recipe = filteredRecipes[index];
                return RecipeCollectionCard(recipe: recipe, index: index);
              },
            );
          },
        );
      },
    );
  }
}
