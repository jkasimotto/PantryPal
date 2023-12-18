import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe_model.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:flutter_recipes/screens/home_screen/recipe_card.dart';
import 'package:provider/provider.dart';

class RecipeListView extends StatelessWidget {
  const RecipeListView({Key? key}) : super(key: key);

  void onChanged(
      BuildContext context, String id, bool? value, RecipeModel recipe) {
    Provider.of<GlobalState>(context, listen: false)
        .updateSelectedRecipes(id, value ?? false, recipe);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<RecipeModel>>(
      valueListenable: Provider.of<GlobalState>(context).recipes,
      builder: (context, recipes, child) {
        String searchQuery = Provider.of<GlobalState>(context).searchQuery;
        int minutesRequired =
            Provider.of<GlobalState>(context).minutesRequired;

        List<RecipeModel> filteredRecipes = recipes.where((recipe) {
          bool matchesSearchQuery = searchQuery.isEmpty ||
              recipe.data.title.contains(searchQuery) ||
              recipe.data.ingredients
                  .any((ingredient) => ingredient!.name.contains(searchQuery));

          return matchesSearchQuery &&
              recipe.data.cookTime + recipe.data.prepTime <= minutesRequired;
        }).toList();

        return ListView.builder(
          itemCount: filteredRecipes.length,
          itemBuilder: (context, index) {
            RecipeModel recipe = filteredRecipes[index];
            return RecipeCard(
              recipe: recipe,
              onChanged: (value) =>
                  onChanged(context, recipe.id, value, recipe),
            );
          },
        );
      },
    );
  }
}

