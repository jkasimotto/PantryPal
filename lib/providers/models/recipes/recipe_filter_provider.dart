import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';

class RecipeFilterProvider extends ChangeNotifier {
  String _searchQuery = '';
  int _minutesRequired = 180;
  int _ingredientsCount = 10;

  String get searchQuery => _searchQuery;
  int get minutesRequired => _minutesRequired;
  int get ingredientsCount => _ingredientsCount;

  void setIngredientsCount(int newIngredientsCount) {
    _ingredientsCount = newIngredientsCount;
    notifyListeners();
  }

  void setSearchQuery(String newQuery) {
    _searchQuery = newQuery;
    notifyListeners();
  }

  void setMinutesRequired(int newMinutesRequired) {
    _minutesRequired = newMinutesRequired;
    notifyListeners();
  }

  List<RecipeModel> filterRecipes(List<RecipeModel> recipes) {
    return recipes.where((recipe) {
      return matchesSearchQuery(recipe) &&
          matchesTimeRequirement(recipe) &&
          matchesIngredientsCountRequirement(recipe);
    }).toList();
  }

  bool matchesSearchQuery(RecipeModel recipe) {
    if (_searchQuery.isEmpty) return true;

    List<String> searchTerms = _searchQuery.toLowerCase().split(' ');
    List<String> recipeContentTerms = [
      recipe.title,
      recipe.notes ?? '',
      recipe.cuisine,
      recipe.course,
      ...recipe.ingredients.map((i) => i.name)
    ].join(' ').toLowerCase().split(' ');

    // Check if each search term is a substring of any of the terms in the recipe content.
    return searchTerms.every((searchTerm) => recipeContentTerms
        .any((contentTerm) => contentTerm.contains(searchTerm)));
  }

  bool matchesTimeRequirement(RecipeModel recipe) {
    return (recipe.cookTime + recipe.prepTime) <= _minutesRequired;
  }

  bool matchesIngredientsCountRequirement(RecipeModel recipe) {
    return recipe.ingredients.length <= _ingredientsCount;
  }
}
