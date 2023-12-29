// lib/controllers/recipe_controller.dart
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_recipes/const/default_recipes.dart';
import 'package:flutter_recipes/models/ingredient/ingredient.dart';
import 'package:flutter_recipes/models/recipe/recipe.dart';
import 'package:flutter_recipes/models/shopping_list/shopping_list.dart';
import 'package:flutter_recipes/models/status.dart';
import 'package:flutter_recipes/models/user/user_model.dart';
import 'package:flutter_recipes/providers/user_provider.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:flutter_recipes/services/ad_service.dart';
import 'package:flutter_recipes/services/cloud_functions_service.dart'
    as cloud_functions;
import 'package:flutter_recipes/services/firestore_service.dart';
import 'package:flutter_recipes/shared/util/image.dart';
import 'package:flutter_recipes/shared/util/json.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';

/// `RecipeController` is a class responsible for managing the recipes.
/// It interacts with Firestore database through `FirestoreService` and updates the state of the home screen via `HomeScreenState`.
/// It handles operations such as recipe extraction from text and images, and deletion.
class RecipeLogicController {
  final FirestoreService firestoreService;
  final GlobalState homeScreenState;
  final UserProvider userProvider; // Added this line
  final AdService adService;
  final uuid = const Uuid();

  RecipeLogicController({
    required this.firestoreService,
    required this.homeScreenState,
    required this.userProvider,
    required this.adService,
  }); // Updated this line

  UserModel? get user {
    if (kDebugMode) {
      print('User: ${userProvider.user}');
    }
    return userProvider.user;
  }

  Future<Recipe> createLoadingRecipe(
      String ownerId, RecipeSource source) async {
    var uuid = const Uuid();
    String id = uuid.v4();

    RecipeMetadata loadingMeta = RecipeMetadata(
        id: id, ownerId: ownerId, source: source, status: Status.loading);

    Recipe loadingRecipe = Recipe(
        title: '',
        ingredients: [],
        method: [],
        cuisine: '',
        course: '',
        servings: 0,
        prepTime: 0,
        cookTime: 0,
        notes: null,
        meta: loadingMeta);

    // Create the loading recipe document in firestore
    firestoreService.createDocument(loadingRecipe, 'recipes');
    return loadingRecipe;
  }

  // Future<void> deleteSelectedRecipes() async {
  //   List<String> recipeIds = homeScreenState.selectedRecipes.values
  //       .map((recipe) => recipe.id)
  //       .toList();
  //   await firestoreService.deleteDocuments(recipeIds, 'recipes');
  //   homeScreenState.removeRecipesByIds(recipeIds);
  //   homeScreenState.clearSelectedRecipes();
  // }

  Future<void> deleteRecipe(String recipeId) async {
    await firestoreService.deleteDocument(recipeId, 'recipes');
    homeScreenState.removeRecipesByIds([recipeId]);
  }

  Future<void> generateShoppingList(BuildContext context) async {
    // Create a loading list
    String listId = uuid.v4();
    String userId = user?.metadata.id ?? '';
    ShoppingList loadingList = ShoppingList(
      recipeTitles: [],
      ingredients: [],
      meta: ShoppingListMetadata(
          id: listId, status: Status.loading, ownerId: userId),
    );
    await firestoreService.createDocument(loadingList, 'lists');

    try {
      if (user?.data.subscriptionPlan == 'free') {
        adService.showInterstitialAd();
      }

      // Get the servings for each selected recipe
      Map<String, int> selectedRecipesServings =
          homeScreenState.selectedRecipesServings;

      // Adjust the ingredients of each selected recipe before combining
      List<Recipe> adjustedRecipes =
          homeScreenState.selectedRecipes.values.map((recipe) {
        int newServings = selectedRecipesServings[recipe.id] ?? recipe.servings;
        List<IngredientWithQuantity> adjustedIngredients =
            recipe.adjustedIngredients(newServings);
        return Recipe(
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

      List<ShoppingListIngredient> combinedIngredients =
          await cloud_functions.combineIngredients(adjustedRecipes);

      // Update the loading list with the actual details
      ShoppingList updatedList = ShoppingList(
        recipeTitles: adjustedRecipes.map((recipe) => recipe.title).toList(),
        ingredients: combinedIngredients,
        meta: ShoppingListMetadata(
            id: listId,
            ownerId: user?.metadata.id ?? '',
            status: Status.success),
      );
      await firestoreService.updateDocument(updatedList, 'lists');
      await cloud_functions.addIngredientIconPathToList(updatedList.id);
    } catch (e) {
      // If an error occurs, set status to error and update the list
      loadingList.meta.status = Status.error;
      await firestoreService.updateDocument(loadingList, 'lists');
      developer.log('Error during shopping list generation: $e');
      rethrow;
    }
  }

  Future<Recipe> _performExtraction(
    Future<Recipe> Function() extractionLogic,
  ) async {
    Recipe? loadingRecipe;
    try {
      // Create a loading recipe document in firestore
      loadingRecipe =
          await createLoadingRecipe(user?.metadata.id ?? '', RecipeSource.text);
    } catch (e) {
      // Handle error when creating the loading recipe
      developer.log('Error creating loading recipe: $e');
      rethrow;
    }

    try {
      // Show ad if user is on free plan
      if (user?.data.subscriptionPlan == 'free') {
        adService.showInterstitialAd();
      }

      // Perform the extraction
      Recipe recipe = await extractionLogic();

      // Update the Recipe with the extracted data and set status to success
      Recipe extractedRecipe = Recipe(
          title: recipe.title,
          ingredients: recipe.ingredients,
          method: recipe.method,
          cuisine: recipe.cuisine,
          course: recipe.course,
          servings: recipe.servings,
          prepTime: recipe.prepTime,
          cookTime: recipe.cookTime,
          notes: recipe.notes,
          meta: loadingRecipe.meta..status = Status.success);

      // Update the document in Firestore
      await firestoreService.updateDocument(extractedRecipe, 'recipes');

      // Add the ingredient icon paths to the ingredients
      cloud_functions.addIngredientIconPathToRecipe(extractedRecipe.meta.id);

      return extractedRecipe;
    } catch (e) {
      // If an error occurs, set status to error
      loadingRecipe.meta.status = Status.error;
      await firestoreService.updateDocument(loadingRecipe, 'recipes');
      developer.log('Error during extraction: $e');
      rethrow;
    }
  }

  Future<void> extractRecipeFromImages(List<XFile> mediaList) async {
    if (mediaList.isNotEmpty) {
      await _performExtraction(() async {
        List<String> base64Images = await imagesToBase64(mediaList);
        return await cloud_functions.extractRecipeFromImages(base64Images);
      });
    }
  }

  Future<void> extractRecipeFromText(String recipeText) async {
    if (isJson(recipeText)) {
      await extractRecipeFromJsonText(recipeText);
    } else {
      developer.log("Invalid JSON recipe.");
      _performExtraction(() async {
        return await cloud_functions.extractRecipeFromText(recipeText);
      });
    }
  }

  Future<void> extractRecipeFromJsonText(String recipeText) async {
    try {
      // Try to decode the text as JSON
      var decodedJson = jsonDecode(recipeText);

      if (decodedJson is List) {
        // If the decoded JSON is a list, iterate over each item and create a Recipe
        List<Recipe> recipes = (decodedJson).map((item) {
          Recipe recipe = Recipe.fromJson(item as Map<String, dynamic>);
          RecipeMetadata metadata = RecipeMetadata(
            id: uuid.v4(), // Generate a new UUID for the recipe
            ownerId: user!.metadata.id, // Use the current user's ID
            source: RecipeSource.text, // Set the source as appropriate
            status: Status.success, // Set the status as appropriate
          );
          return recipe.generateNewRecipeFromMeta(metadata);
        }).toList();
        developer.log("Valid JSON list of recipes");
        for (var recipe in recipes) {
          firestoreService.createDocument(recipe, 'recipes');
        }
      } else if (decodedJson is Map) {
        // If the decoded JSON is a map, create a single Recipe
        Recipe recipeFromJson =
            Recipe.fromJson(decodedJson as Map<String, dynamic>);
        RecipeMetadata metadata = RecipeMetadata(
          id: uuid.v4(), // Generate a new UUID for the recipe
          ownerId: user?.metadata.id ?? '', // Use the current user's ID
          source: RecipeSource.text, // Set the source as appropriate
          status: Status.success, // Set the status as appropriate
        );
        Recipe recipe = recipeFromJson.generateNewRecipeFromMeta(metadata);
        developer.log("Valid JSON recipe");
        firestoreService.createDocument(recipe, 'recipes');
      } else {
        throw const FormatException('Invalid JSON format');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> extractRecipeFromWebUrl(String url) async {
    try {
      await _performExtraction(() async {
        return await cloud_functions.extractRecipeFromWebpage(url);
      });
    } catch (e) {
      developer.log("Invalid recipe from webpage.");
    }
  }

  Future<void> createInitialRecipes(
      String userId, FirestoreService firestoreService) async {
    List<Recipe> defaultRecipes = [
      getBaconAndEggsRecipe(),
      getSoftBoiledEggRecipe()
    ];
    for (var defaultRecipe in defaultRecipes) {
      RecipeMetadata metadata = RecipeMetadata(
        id: uuid.v4(), // Generate a new UUID for the recipe
        ownerId: userId, // Use the current user's ID
        source: RecipeSource.text, // Set the source as appropriate
        status: Status.success, // Set the status as appropriate
      );
      Recipe recipe = defaultRecipe.generateNewRecipeFromMeta(metadata);
      developer.log("Created initial recipe");
      firestoreService.createDocument(recipe, 'recipes');
    }
  }
}
