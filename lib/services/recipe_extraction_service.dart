import 'dart:convert';
import 'dart:io';

import 'package:flutter_recipes/models/ingredient_model.dart';
import 'package:flutter_recipes/models/recipe_method_step_model.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_recipes/models/recipe_model.dart';
import 'package:flutter_recipes/services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_recipes/services/cloud_functions_service.dart'
    as cloud_functions;

class RecipeExtractionService {
  static RecipeModel createLoadingRecipe(String ownerId, Source source) {
    var uuid = const Uuid();
    String id = uuid.v4();

    RecipeData loadingRecipeData = RecipeData(
      title: '',
      ingredients: [],
      method: [],
      cuisine: '',
      course: '',
      servings: 0,
      prepTime: 0,
      cookTime: 0,
      notes: null,
    );
    RecipeMetadata loadingMetadata = RecipeMetadata(
        id: id, ownerId: ownerId, source: source, status: Status.loading);
    return RecipeModel(data: loadingRecipeData, metadata: loadingMetadata);
  }

  static Future<RecipeModel> _performExtraction(
      Future<RecipeData> Function() extractionLogic,
      RecipeModel loadingRecipe,
      FirestoreService firestoreService) async {
    try {
      // Perform the extraction
      RecipeData recipeData = await extractionLogic();

      // Update the RecipeModel with the extracted data and set status to success
      RecipeModel extractedRecipe = RecipeModel(
          data: recipeData,
          metadata: loadingRecipe.metadata..status = Status.success);

      // Update the document in Firestore
      await firestoreService.updateDocument(extractedRecipe, 'recipes');

      return extractedRecipe;
    } catch (e) {
      // If an error occurs, set status to error
      loadingRecipe.metadata.status = Status.error;
      await firestoreService.updateDocument(loadingRecipe, 'recipes');
      rethrow;
    }
  }

  static Future<RecipeModel> extractRecipeFromImages(List<XFile> mediaList,
      String ownerId, FirestoreService firestoreService) async {
    RecipeModel loadingRecipe = createLoadingRecipe(ownerId, Source.image);
    loadingRecipe.metadata.status = Status.loading;

    // Save the loading RecipeModel to Firestore
    await firestoreService.createDocument(loadingRecipe, 'recipes');

    return _performExtraction(() async {
      List<String> base64Images = await _imagesToBase64(mediaList);
      return await cloud_functions.extractRecipeFromImages(base64Images);
    }, loadingRecipe, firestoreService);
  }

  static Future<RecipeModel> extractRecipeFromText(String recipeText,
      String ownerId, FirestoreService firestoreService) async {
    try {
      // Try to decode the text as JSON and create a RecipeModel from it
      Map<String, dynamic> recipeJson = jsonDecode(recipeText);
      RecipeModel recipe = RecipeModel.fromJson(recipeJson);

      // If the above lines didn't throw an error, the text is a valid RecipeModel JSON
      // So, we can return the created RecipeModel immediately
      return recipe;
    } catch (e) {
      // If an error was thrown, the text is not a valid RecipeModel JSON
      // So, we proceed with the existing extraction logic

      RecipeModel loadingRecipe = createLoadingRecipe(ownerId, Source.text);
      loadingRecipe.metadata.status = Status.loading;

      // Save the loading RecipeModel to Firestore
      await firestoreService.createDocument(loadingRecipe, 'recipes');

      return _performExtraction(() async {
        return await cloud_functions.extractRecipeDataFromText(recipeText);
      }, loadingRecipe, firestoreService);
    }
  }

  static Future<RecipeModel> extractRecipeFromYoutube(
      String url, String ownerId, FirestoreService firestoreService) async {
    RecipeModel loadingRecipe = createLoadingRecipe(ownerId, Source.youtube);
    loadingRecipe.metadata.status = Status.loading;

    // Save the loading RecipeModel to Firestore
    await firestoreService.createDocument(loadingRecipe, 'recipes');

    return _performExtraction(() async {
      String transcript = await cloud_functions.transcribeYoutubeVideo(url);
      return await cloud_functions.extractRecipeDataFromText(transcript);
    }, loadingRecipe, firestoreService);
  }

  static Future<RecipeModel> extractRecipeFromWebpage(
      String url, String ownerId, FirestoreService firestoreService) async {
    RecipeModel loadingRecipe = createLoadingRecipe(ownerId, Source.webpage);
    loadingRecipe.metadata.status = Status.loading;

    // Save the loading RecipeModel to Firestore
    await firestoreService.createDocument(loadingRecipe, 'recipes');

    return _performExtraction(() async {
      return await cloud_functions.extractRecipeFromWebpage(url);
    }, loadingRecipe, firestoreService);
  }

  static Future<List<String>> _imagesToBase64(List<XFile> mediaList) async {
    List<String> base64Images = [];
    for (var media in mediaList) {
      File imageFile = File(media.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      base64Images.add(base64Image);
    }
    return base64Images;
  }

  Future<List<RecipeModel>> createInitialRecipes(
      String userId, FirestoreService firestoreService) async {
    // Ingredient data for soft boiled egg
    IngredientData egg = IngredientData(
      name: 'Egg',
      quantity: QuantityData(value: 1, units: 'piece'),
      form: 'Whole',
      category: 'Protein',
      allergens: [],
      substitutions: [],
      nutritionalInformation: NutritionalInformation(
        calories: 68,
        fats: 4.8,
        carbohydrates: 0.6,
        proteins: 5.5,
        vitamins: 10,
        minerals: 12,
      ),
      shelfLife: "21 days",
      seasonality: "All Year",
    );

    // Recipe 1: Soft boiled egg
    RecipeModel softBoiledEgg = RecipeModel(
      data: RecipeData(
        title: 'Soft boiled egg',
        ingredients: [egg],
        method: [
          RecipeMethodStepData(stepNumber: 1, description: 'boil water'),
          RecipeMethodStepData(
              stepNumber: 2, description: 'put egg in water for 6 minutes')
        ],
        cuisine: 'Global',
        course: 'Breakfast',
        servings: 1,
        prepTime: 4,
        cookTime: 6,
        notes: 'Serve with toast for a complete breakfast.',
      ),
      metadata: RecipeMetadata(
        id: 'recipe1',
        ownerId: userId,
        source: Source.text,
        status: Status.success,
      ),
    );

    // Ingredient data for eggs and bacon
    IngredientData bacon = IngredientData(
      name: 'Bacon',
      quantity: QuantityData(value: 2, units: 'slices'),
      form: 'Sliced',
      category: 'Protein',
      allergens: [],
      substitutions: [],
      nutritionalInformation: NutritionalInformation(
        calories: 42,
        fats: 3.3,
        carbohydrates: 0.1,
        proteins: 3,
        vitamins: 0,
        minerals: 1,
      ),
      shelfLife: "7 days",
      seasonality: "All Year",
    );

    // Recipe 2: Eggs and bacon
    RecipeModel eggsAndBacon = RecipeModel(
      data: RecipeData(
        title: 'Eggs and bacon',
        ingredients: [egg, bacon],
        method: [
          RecipeMethodStepData(
              stepNumber: 1, description: 'fry bacon until crispy'),
          RecipeMethodStepData(
              stepNumber: 2, description: 'fry egg to desired doneness'),
          RecipeMethodStepData(
              stepNumber: 3, description: 'serve egg with bacon on the side')
        ],
        cuisine: 'American',
        course: 'Breakfast',
        servings: 1,
        prepTime: 5,
        cookTime: 10,
        notes: 'Serve with toast and a glass of orange juice.',
      ),
      metadata: RecipeMetadata(
        id: 'recipe2',
        ownerId: userId,
        source: Source.text,
        status: Status.success,
      ),
    );

    // Save the recipes to Firestore
    await firestoreService.createDocument(softBoiledEgg, 'recipes');
    await firestoreService.createDocument(eggsAndBacon, 'recipes');
    return [softBoiledEgg, eggsAndBacon];
  }
}
