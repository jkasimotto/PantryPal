import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_provider.dart';
import 'package:flutter_recipes/services/firebase/firestore_service.dart';
import 'package:flutter_recipes/services/business/recipe_service.dart';
import 'package:share/share.dart';

class SelectedRecipeProvider extends ChangeNotifier {
  final Map<String, RecipeModel> _selectedRecipes = {};
  final Map<String, int> _selectedRecipesServings = {};
  final RecipeProvider recipeProvider; // Added this line
  final RecipeService recipeService;

  SelectedRecipeProvider(
      {required this.recipeProvider, required this.recipeService}) {}

  Map<String, RecipeModel> get selectedRecipes => _selectedRecipes;
  Map<String, int> get selectedRecipesServings => _selectedRecipesServings;

  Future<void> deleteSelectedRecipes() async {
    List<String> recipeIds =
        _selectedRecipes.values.map((recipe) => recipe.id).toList();
    recipeService.deleteRecipes(recipeIds);
    clearSelectedRecipes();
  }

  void updateSelectedRecipes(String id, bool value, RecipeModel recipe) {
    if (value == true) {
      _selectedRecipes[id] = recipe;
    } else {
      _selectedRecipes.remove(id);
    }
    notifyListeners();
  }

  void updateSelectedRecipeServings(String recipeId, int servings) {
    _selectedRecipesServings[recipeId] = servings;
    notifyListeners();
  }

  void clearSelectedRecipes() {
    _selectedRecipes.clear();
    _selectedRecipesServings.clear();
    notifyListeners();
  }

  void copySelectedRecipesToClipboard() {
    String recipesText =
        _selectedRecipes.values.map((recipe) => recipe.title).join('\n');
    Clipboard.setData(ClipboardData(text: recipesText));
  }

  void shareSelectedRecipes() {
    String recipesJson = jsonEncode(
        _selectedRecipes.values.map((recipe) => recipe.toJson()).toList());
    Share.share(recipesJson);
  }

  void selectDefaultRecipesWhenAvailable() {
    // Moved this method here
    // Listen to the recipes ValueNotifier
    recipeProvider.recipes.addListener(() {
      // Check if there are two recipes
      if (recipeProvider.recipes.value.length == 2) {
        // Get the two default recipes
        RecipeModel softBoiledEgg = recipeProvider.recipes.value[0];
        RecipeModel eggBagel = recipeProvider.recipes.value[1];

        // Select the recipes
        updateSelectedRecipes(softBoiledEgg.id, true, softBoiledEgg);
        updateSelectedRecipes(eggBagel.id, true, eggBagel);

        // Remove the listener after the selection is done
        recipeProvider.recipes
            .removeListener(selectDefaultRecipesWhenAvailable);
      }
    });
  }
}
