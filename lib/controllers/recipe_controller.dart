// lib/controllers/recipe_controller.dart
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_recipes/models/ingredient_model.dart';
import 'package:flutter_recipes/models/recipe_model.dart';
import 'package:flutter_recipes/models/user_model.dart';
import 'package:flutter_recipes/providers/user_provider.dart';
import 'package:flutter_recipes/screens/home_screen/home_screen.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:flutter_recipes/screens/home_screen/shopping_list.dart';
import 'package:flutter_recipes/services/ad_service.dart';
import 'package:flutter_recipes/services/cloud_functions_service.dart'
    as cloud_functions;
import 'package:flutter_recipes/services/firestore_service.dart';
import 'package:flutter_recipes/services/recipe_extraction_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

/// `RecipeController` is a class responsible for managing the recipes.
/// It interacts with Firestore database through `FirestoreService` and updates the state of the home screen via `HomeScreenState`.
/// It handles operations such as recipe extraction from text and images, and deletion.
class RecipeController {
  final FirestoreService firestoreService;
  final GlobalState homeScreenState;
  final UserProvider userProvider; // Added this line
  final AdService adService;
  final uuid = const Uuid();

  RecipeController({
    required this.firestoreService,
    required this.homeScreenState,
    required this.userProvider,
    required this.adService,
  }); // Updated this line

  UserModel? get user {
    print('User: ${userProvider.user}');
    return userProvider.user;
  }

  Future<void> deleteSelectedRecipes() async {
    List<String> recipeIds = homeScreenState.selectedRecipes.values
        .map((recipe) => recipe.id)
        .toList();
    await firestoreService.deleteDocuments(recipeIds, 'recipes');
    homeScreenState.removeRecipesByIds(recipeIds);
    homeScreenState.clearSelectedRecipes();
  }

  Future<void> deleteRecipe(String recipeId) async {
    await firestoreService.deleteDocument(recipeId, 'recipes');
    homeScreenState.removeRecipesByIds([recipeId]);
  }

  Future<void> handleRecipeExtractionFromText(
      BuildContext context, String recipeText) async {
    try {
      String ownerId = user?.metadata.id ?? ''; // Updated this line
      await RecipeExtractionService.extractRecipeFromText(
          recipeText, ownerId, firestoreService);
      homeScreenState.setLoadingState(LoadingState.idle);
      user?.metadata.recipeGenerationCount['text'] =
          (user?.metadata.recipeGenerationCount['text'] ?? 0) + 1;
      user?.metadata.hasCompletedTextAction = true; // Added this line
    } catch (error) {
      print('Error extracting recipe: $error');
      homeScreenState.setLoadingState(LoadingState.idle);
    }
  }

  void copySelectedRecipesToClipboard() {
    String recipesText = homeScreenState.selectedRecipes.values
        .map((recipe) => recipe.data.title)
        .join('\n');
    Clipboard.setData(ClipboardData(text: recipesText));
  }

  void generateShoppingList(BuildContext context) {
    // Get the servings for each selected recipe
    Map<String, int> selectedRecipesServings =
        homeScreenState.selectedRecipesServings;

    // Adjust the ingredients of each selected recipe before combining
    List<RecipeModel> adjustedRecipes =
        homeScreenState.selectedRecipes.values.map((recipe) {
      int newServings =
          selectedRecipesServings[recipe.id] ?? recipe.data.servings;
      List<IngredientData> adjustedIngredients =
          recipe.data.adjustedIngredients(newServings);
      RecipeData adjustedRecipeData = RecipeData(
        title: recipe.data.title,
        ingredients: adjustedIngredients,
        method: recipe.data.method,
        cuisine: recipe.data.cuisine,
        course: recipe.data.course,
        servings: newServings,
        prepTime: recipe.data.prepTime,
        cookTime: recipe.data.cookTime,
        notes: recipe.data.notes,
      );
      return RecipeModel(data: adjustedRecipeData, metadata: recipe.metadata);
    }).toList();

    Future<String> combinedIngredients =
        cloud_functions.combineIngredients(adjustedRecipes);

    showDialog(
      context: context,
      builder: (BuildContext innerContext) {
        return ShoppingList(
          shoppingListFuture: combinedIngredients,
        );
      },
    );
  }

  Future<void> handleImageSelection(List<XFile> mediaList) async {
    if (mediaList.isNotEmpty) {
      if (user?.data.subscriptionPlan == 'free') {
        adService.showInterstitialAd();
      }
      String ownerId = user?.metadata.id ?? '';
      await RecipeExtractionService.extractRecipeFromImages(
          mediaList, ownerId, firestoreService);
      homeScreenState.setLoadingState(LoadingState.idle);
      user?.metadata.hasCompletedCameraAction = true; // Added this line
    }
  }

  Future<void> handleYoutubeSelection(String url) async {
    if (user?.data.subscriptionPlan == 'free') {
      adService.showInterstitialAd();
    }
    String ownerId = user?.metadata.id ?? '';
    await RecipeExtractionService.extractRecipeFromYoutube(
        url, ownerId, firestoreService);
    homeScreenState.setLoadingState(LoadingState.idle);
    user?.metadata.recipeGenerationCount['youtube'] =
        (user?.metadata.recipeGenerationCount['youtube'] ?? 0) + 1;
    user?.metadata.hasCompletedYoutubeAction = true; // Added this line
  }

  Future<void> handleTextSelection(String recipeText) async {
    try {
      // Try to decode the text as JSON
      var decodedJson = jsonDecode(recipeText);

      if (decodedJson is List) {
        // If the decoded JSON is a list, iterate over each item and create a RecipeModel
        List<RecipeModel> recipes = (decodedJson as List).map((item) {
          RecipeData data = RecipeData.fromJson(item as Map<String, dynamic>);
          RecipeMetadata metadata = RecipeMetadata(
            id: uuid.v4(), // Generate a new UUID for the recipe
            ownerId: user!.metadata.id, // Use the current user's ID
            source: Source.text, // Set the source as appropriate
            status: Status.success, // Set the status as appropriate
          );
          return RecipeModel(data: data, metadata: metadata);
        }).toList();
        developer.log("Valid JSON list of recipes");
        for (var recipe in recipes) {
          firestoreService.createDocument(recipe, 'recipes');
        }
      } else if (decodedJson is Map) {
        // If the decoded JSON is a map, create a single RecipeModel
        RecipeData data =
            RecipeData.fromJson(decodedJson as Map<String, dynamic>);
        RecipeMetadata metadata = RecipeMetadata(
          id: uuid.v4(), // Generate a new UUID for the recipe
          ownerId: user?.metadata.id ?? '', // Use the current user's ID
          source: Source.text, // Set the source as appropriate
          status: Status.success, // Set the status as appropriate
        );
        RecipeModel recipe = RecipeModel(data: data, metadata: metadata);
        developer.log("Valid JSON recipe");
        firestoreService.createDocument(recipe, 'recipes');
      } else {
        throw const FormatException('Invalid JSON format');
      }
    } catch (e) {
      developer.log("Invalid JSON recipe.");
      if (user?.data.subscriptionPlan == 'free') {
        adService.showInterstitialAd();
      }
      String ownerId = user!.metadata.id;
      await RecipeExtractionService.extractRecipeFromText(
          recipeText, ownerId, firestoreService);
      homeScreenState.setLoadingState(LoadingState.idle);
      user?.metadata.hasCompletedTextAction = true; // Added this line
    }
  }

  Future<void> handleUrlSelection(String url) async {
    try {
      String ownerId = user!.metadata.id;
      await RecipeExtractionService.extractRecipeFromWebpage(
          url, ownerId, firestoreService);
      developer.log("Valid recipe from webpage");
      homeScreenState.setLoadingState(LoadingState.idle);
      user?.metadata.recipeGenerationCount['web'] =
          (user?.metadata.recipeGenerationCount['web'] ?? 0) + 1;
      user?.metadata.hasCompletedWebAction = true; // Added this line
    } catch (e) {
      developer.log("Invalid recipe from webpage.");
      homeScreenState.setLoadingState(LoadingState.idle);
    }
  }
}
