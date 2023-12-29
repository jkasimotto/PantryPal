import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe.dart';
import 'package:flutter_recipes/screens/recipe_collection_screen.dart/recipe_collection_card/recipe_collection_card.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:provider/provider.dart';

class RecipeCollectionListView extends StatelessWidget {
  const RecipeCollectionListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(
      builder: (context, globalState, child) {
        return ValueListenableBuilder<List<Recipe>>(
          valueListenable: globalState.recipes,
          builder: (context, recipes, child) {
            List<Recipe> filteredRecipes = globalState.filteredRecipes;

            return ListView.builder(
              itemCount: filteredRecipes.length,
              itemBuilder: (context, index) {
                Recipe recipe = filteredRecipes[index];
                return RecipeCollectionCard(
                  recipe: recipe,
                  onChanged: (value) =>
                      _onChanged(context, recipe.id, value, recipe),
                );
              },
            );
          },
        );
      },
    );
  }

  void _onChanged(BuildContext context, String id, bool? value, Recipe recipe) {
    Provider.of<GlobalState>(context, listen: false)
        .updateSelectedRecipes(id, value ?? false, recipe);
  }
}

extension on GlobalState {
  List<Recipe> get filteredRecipes {
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
