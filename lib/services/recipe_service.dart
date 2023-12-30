// lib/controllers/recipe_controller.dart
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_recipes/const/default_recipes.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_model.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/models/status.dart';
import 'package:flutter_recipes/models/user/user_model.dart';
import 'package:flutter_recipes/providers/recipe_provider.dart';
import 'package:flutter_recipes/providers/user_provider.dart';
import 'package:flutter_recipes/services/ad_service.dart';
import 'package:flutter_recipes/services/cloud_functions_service.dart'
    as cloud_functions;
import 'package:flutter_recipes/services/firestore_service.dart';
import 'package:flutter_recipes/shared/util/image.dart';
import 'package:flutter_recipes/shared/util/json.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

/// `RecipeController` is a class responsible for managing the recipes.
/// It interacts with Firestore database through `FirestoreService` and updates the state of the home screen via `HomeScreenState`.
/// It handles operations such as recipe extraction from text and images, and deletion.
class RecipeService {
  final FirestoreService firestoreService;
  final UserProvider userProvider; // Added this line
  final AdService adService;
  final RecipeProvider recipeProvider;
  final uuid = const Uuid();

  RecipeService({
    required this.firestoreService,
    required this.userProvider,
    required this.adService,
    required this.recipeProvider,
  }); // Updated this line

  UserModel? get user {
    if (kDebugMode) {
      print('User: ${userProvider.user}');
    }
    return userProvider.user;
  }

  Future<RecipeModel> createLoadingRecipe(
      String ownerId, RecipeSource source) async {
    var uuid = const Uuid();
    String id = uuid.v4();

    RecipeMetadata loadingMeta = RecipeMetadata(
        id: id, ownerId: ownerId, source: source, status: Status.loading);

    RecipeModel loadingRecipe = RecipeModel(
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

  Future<void> deleteRecipe(String recipeId) async {
    await firestoreService.deleteDocument(recipeId, 'recipes');
    recipeProvider.removeRecipesByIds([recipeId]);
  }

  Future<void> deleteRecipes(List<String> recipeIds) async {
    firestoreService.deleteDocuments(recipeIds, 'recipes');
  }

  Future<RecipeModel> _performExtraction(
    Future<RecipeModel> Function() extractionLogic,
  ) async {
    RecipeModel? loadingRecipe;
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
      RecipeModel recipe = await extractionLogic();

      // Update the Recipe with the extracted data and set status to success
      RecipeModel extractedRecipe = RecipeModel(
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
        List<RecipeModel> recipes = (decodedJson).map((item) {
          RecipeModel recipe =
              RecipeModel.fromJson(item as Map<String, dynamic>);
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
        RecipeModel recipeFromJson =
            RecipeModel.fromJson(decodedJson as Map<String, dynamic>);
        RecipeMetadata metadata = RecipeMetadata(
          id: uuid.v4(), // Generate a new UUID for the recipe
          ownerId: user?.metadata.id ?? '', // Use the current user's ID
          source: RecipeSource.text, // Set the source as appropriate
          status: Status.success, // Set the status as appropriate
        );
        RecipeModel recipe = recipeFromJson.generateNewRecipeFromMeta(metadata);
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
    List<RecipeModel> defaultRecipes = [
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
      RecipeModel recipe = defaultRecipe.generateNewRecipeFromMeta(metadata);
      developer.log("Created initial recipe");
      firestoreService.createDocument(recipe, 'recipes');
    }
  }

  // Method to add an ingredient to a specific recipe
  Future<void> addIngredientToRecipe(
      String recipeId, IngredientWithQuantity newIngredient) async {
    // Check if the recipe id exists in the list
    if (!recipeProvider.recipes.value.any((recipe) => recipe.id == recipeId)) {
      // Handle the case where the recipe id doesn't exist
      developer.log('Recipe not found: $recipeId', name: 'RecipeService');
      return;
    }
    // Find the recipe by id
    RecipeModel? recipe = recipeProvider.recipes.value
        .firstWhere((recipe) => recipe.id == recipeId);

    // If the ingredientId is empty, create a new ingredient document
    if (newIngredient.meta.ingredientId == null ||
        newIngredient.meta.ingredientId!.isEmpty) {
      String newIngredientId = uuid.v4();
      IngredientMeta newIngredientMeta =
          newIngredient.meta.copyWith(ingredientId: newIngredientId);
      Ingredient newIngredientModel =
          Ingredient(name: newIngredient.name, meta: newIngredientMeta);
      await firestoreService.createDocument(newIngredientModel, 'ingredients');

      newIngredient = newIngredient.copyWith(meta: newIngredientMeta);
    }

    // If the recipe exists, add the new ingredient
    RecipeModel updatedRecipe = recipe.addIngredient(newIngredient);

    // Update the recipe in the provider
    recipeProvider.setRecipes(recipeProvider.recipes.value
        .map((r) => r.id == recipeId ? updatedRecipe : r)
        .toList());

    // Update the recipe in Firestore
    await firestoreService.updateDocument(updatedRecipe, 'recipes');
  }

  // Method to edit an ingredient in a specific recipe
  Future<void> editIngredientInRecipe(
      String recipeId, IngredientWithQuantity editedIngredient) async {
    // Check if the recipe id exists in the list
    if (!recipeProvider.recipes.value.any((recipe) => recipe.id == recipeId)) {
      // Handle the case where the recipe id doesn't exist
      // For example, you can log an error message and return
      developer.log('Recipe not found: $recipeId', name: 'RecipeService');
      return;
    }
    // Find the recipe by id
    RecipeModel? recipe = recipeProvider.recipes.value
        .firstWhere((recipe) => recipe.id == recipeId);

    // If the recipe exists, edit the ingredient
    RecipeModel updatedRecipe = recipe.editIngredient(editedIngredient);

    // Update the recipe in the provider
    recipeProvider.setRecipes(recipeProvider.recipes.value
        .map((r) => r.id == recipeId ? updatedRecipe : r)
        .toList());

    // Update the recipe in Firestore
    await firestoreService.updateDocument(updatedRecipe, 'recipes');
  }

  // Method to remove an ingredient from a specific recipe
  Future<void> removeIngredientFromRecipe(
      String recipeId, IngredientWithQuantity ingredientToRemove) async {
    // Check if the recipe id exists in the list
    if (!recipeProvider.recipes.value.any((recipe) => recipe.id == recipeId)) {
      // Handle the case where the recipe id doesn't exist
      developer.log('Recipe not found: $recipeId', name: 'RecipeService');
      return;
    }
    // Find the recipe by id
    RecipeModel? recipe = recipeProvider.recipes.value
        .firstWhere((recipe) => recipe.id == recipeId);

    // If the recipe exists, remove the ingredient
    RecipeModel updatedRecipe = recipe.removeIngredient(ingredientToRemove.id);

    // Update the recipe in the provider
    recipeProvider.setRecipes(recipeProvider.recipes.value
        .map((r) => r.id == recipeId ? updatedRecipe : r)
        .toList());

    // Update the recipe in Firestore
    await firestoreService.updateDocument(updatedRecipe, 'recipes');
  }
}
