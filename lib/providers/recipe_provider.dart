import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/providers/user_provider.dart';
import 'package:flutter_recipes/services/firestore_service.dart';
import 'dart:developer' as developer;

class RecipeProvider extends ChangeNotifier {
  final UserProvider userProvider;
  final FirestoreService firestoreService = FirestoreService();
  final ValueNotifier<List<RecipeModel>> _recipes =
      ValueNotifier<List<RecipeModel>>([]);
  final ValueNotifier<RecipeModel?> recipeNotifier =
      ValueNotifier<RecipeModel?>(null); // Added this line
  Stream<List<RecipeModel>>? _recipeStream;

  RecipeProvider({required this.userProvider}) {
    userProvider.addListener(_updateRecipeStream);
    _updateRecipeStream();
  }

  ValueNotifier<List<RecipeModel>> get recipes => _recipes;

  void _updateRecipeStream() {
    if (userProvider.user != null) {
      developer.log('User updated: ${userProvider.user}',
          name: 'RecipeProvider');
      _recipeStream =
          firestoreService.listenToUserRecipes(userProvider.user!.id);
      _streamRecipes();
    } else {
      _recipeStream = null;
    }
  }

  void _streamRecipes() {
    _recipeStream?.listen((newRecipes) {
      developer.log("NewRecipes: $newRecipes");
      _recipes.value = newRecipes;
    });
  }

  void setRecipes(List<RecipeModel> newRecipes) {
    _recipes.value = newRecipes;
  }

  void setRecipe(RecipeModel newRecipe) {
    // Added this line
    recipeNotifier.value = newRecipe; // Added this line
  } // Added this line

  void removeRecipesByIds(List<String> recipeIds) {
    for (var id in recipeIds) {
      _recipes.value.removeWhere((recipe) => recipe.id == id);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    userProvider.removeListener(_updateRecipeStream);
    super.dispose();
  }
}
