import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_model.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/models/shopping_list/shopping_list_model.dart';
import 'package:flutter_recipes/models/status.dart';
import 'package:flutter_recipes/models/user/user_model.dart';
import 'package:flutter_recipes/providers/selected_recipes_provider.dart';
import 'package:flutter_recipes/providers/user_provider.dart';
import 'package:flutter_recipes/services/ad_service.dart';
import 'package:flutter_recipes/services/firestore_service.dart';
import 'package:flutter_recipes/services/cloud_functions_service.dart'
    as cloud_functions;
import 'package:uuid/uuid.dart';

class RecipeToListConverter {
  final UserProvider userProvider;
  final AdService adService;
  final SelectedRecipeProvider selectedRecipeProvider;
  final FirestoreService firestoreService;
  final Uuid uuid;

  RecipeToListConverter({
    required this.userProvider,
    required this.adService,
    required this.selectedRecipeProvider,
    required this.firestoreService,
    required this.uuid,
  });

  Future<void> generateShoppingList() async {
    UserModel? user = userProvider.user;
    String listId = uuid.v4();
    String userId = user?.metadata.id ?? '';

    ShoppingList loadingList = await createLoadingList(listId, userId);
    await showAdIfUserIsFree(user);
    List<RecipeModel> adjustedRecipes = await adjustSelectedRecipes();
    await updateListWithActualDetails(loadingList, adjustedRecipes);
  }

  Future<ShoppingList> createLoadingList(String listId, String userId) async {
    ShoppingList loadingList = ShoppingList(
      recipeTitles: [],
      ingredients: [],
      meta: ShoppingListMetadata(
          id: listId, status: Status.loading, ownerId: userId),
    );
    await firestoreService.createDocument(loadingList, 'lists');
    return loadingList;
  }

  Future<void> showAdIfUserIsFree(UserModel? user) async {
    if (user?.data.subscriptionPlan == 'free') {
      adService.showInterstitialAd();
    }
  }

  Future<List<RecipeModel>> adjustSelectedRecipes() async {
    Map<String, int> selectedRecipesServings =
        selectedRecipeProvider.selectedRecipesServings;

    List<RecipeModel> adjustedRecipes =
        selectedRecipeProvider.selectedRecipes.values.map((recipe) {
      int newServings = selectedRecipesServings[recipe.id] ?? recipe.servings;
      List<IngredientWithQuantity> adjustedIngredients =
          recipe.adjustedIngredients(newServings);
      return RecipeModel(
          title: recipe.title,
          ingredients: adjustedIngredients,
          method: recipe.method,
          cuisine: recipe.cuisine,
          course: recipe.course,
          servings: newServings,
          prepTime: recipe.prepTime,
          cookTime: recipe.cookTime,
          notes: recipe.notes,
          meta: recipe.meta);
    }).toList();

    return adjustedRecipes;
  }

  Future<void> updateListWithActualDetails(
      ShoppingList loadingList, List<RecipeModel> adjustedRecipes) async {
    try {
      List<ShoppingListIngredient> combinedIngredients =
          await cloud_functions.combineIngredients(adjustedRecipes);
      ShoppingList updatedList = ShoppingList(
        recipeTitles: adjustedRecipes.map((recipe) => recipe.title).toList(),
        ingredients: combinedIngredients,
        meta: ShoppingListMetadata(
            id: loadingList.meta.id,
            ownerId: loadingList.meta.ownerId,
            status: Status.success),
      );
      await firestoreService.updateDocument(updatedList, 'lists');
      await cloud_functions.addIngredientIconPathToList(updatedList.id);
    } catch (e) {
      loadingList.meta.status = Status.error;
      await firestoreService.updateDocument(loadingList, 'lists');
      developer.log('Error during shopping list generation: $e');
      rethrow;
    }
  }
}
