import 'package:flutter/foundation.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';

class ShoppingListProvider with ChangeNotifier {
  List<RecipeModel> _selectedRecipes;

  ShoppingListProvider({required List<RecipeModel> initialRecipes})
      : _selectedRecipes = initialRecipes;

  List<RecipeModel> get selectedRecipes => _selectedRecipes;

  set selectedRecipes(List<RecipeModel> recipes) {
    _selectedRecipes = recipes;
    notifyListeners();
  }

  void addRecipe(RecipeModel recipe) {
    _selectedRecipes.add(recipe);
    notifyListeners();
  }

  void removeRecipe(RecipeModel recipe) {
    _selectedRecipes.remove(recipe);
    notifyListeners();
  }
}