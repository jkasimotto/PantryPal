import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_filter_provider.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_provider.dart';
import 'package:flutter_recipes/screens/collections/recipe_collection_screen/recipe_collection_card.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:provider/provider.dart';

class RecipeCollectionListView extends StatelessWidget {
  const RecipeCollectionListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    final recipeFilterProvider =
        Provider.of<RecipeFilterProvider>(context, listen: false);

    return Consumer<GlobalState>(
      builder: (context, globalState, child) {
        return ValueListenableBuilder<List<RecipeModel>>(
          valueListenable:
              recipeProvider.recipes, // Updated to use RecipeProvider
          builder: (context, recipes, child) {
            List<RecipeModel> filteredRecipes =
                recipeFilterProvider.filterRecipes(
                    recipes); // Using RecipeFilterProvider's filter method

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
