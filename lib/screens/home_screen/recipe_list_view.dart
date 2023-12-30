import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/screens/recipe_collection_screen.dart/recipe_collection_card/recipe_collection_card.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:provider/provider.dart';

class RecipeCollectionListView extends StatelessWidget {
  const RecipeCollectionListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(
      builder: (context, globalState, child) {
        return ValueListenableBuilder<List<RecipeModel>>(
          valueListenable: globalState.recipes,
          builder: (context, recipes, child) {
            List<RecipeModel> filteredRecipes = globalState.filteredRecipes;

            return ListView.builder(
              itemCount: filteredRecipes.length,
              itemBuilder: (context, index) {
                RecipeModel recipe = filteredRecipes[index];
                return RecipeCollectionCard(
                  recipe: recipe,
                );
              },
            );
          },
        );
      },
    );
  }
}

extension on GlobalState {
  List<RecipeModel> get filteredRecipes {
    return recipes.value.where((recipe) {
      bool matchesSearchQuery = searchQuery.isEmpty ||
          recipe.title.contains(searchQuery) ||
          recipe.ingredients
              .any((ingredient) => ingredient.name.contains(searchQuery));

      return matchesSearchQuery &&
          recipe.cookTime + recipe.prepTime <= minutesRequired;
    }).toList();
  }
}
