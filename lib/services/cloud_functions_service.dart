import 'dart:developer' as developer;
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/models/shopping_list/shopping_list_model.dart';

Future<String> transcribeAudio(String audioBase64) async {
  try {
    // Call the function
    final result = await FirebaseFunctions.instance
        .httpsCallable('transcribe_audio')
        .call({'audio': audioBase64});

    // Return the transcript
    return result.data['transcript'] as String;
  } on FirebaseFunctionsException catch (error) {
    print('Error code: ${error.code}');
    print('Error message: ${error.message}');
    print('Error details: ${error.details}');
    return Future.error(error);
  }
}

Future<String> transcribeYoutubeVideo(String videoUrl) async {
  try {
    // Call the function
    final result = await FirebaseFunctions.instance
        .httpsCallable('transcribe_youtube_video')
        .call({'url': videoUrl});

    // Check the status of the result
    if (result.data['status'] == 'success') {
      // Return the transcript
      return result.data['transcript'] as String;
    } else {
      // Throw an error with the error message
      throw Exception(result.data['error']);
    }
  } on FirebaseFunctionsException catch (error) {
    print('Error code: ${error.code}');
    print('Error message: ${error.message}');
    print('Error details: ${error.details}');
    return Future.error(error);
  }
}

Future<List<ShoppingListIngredientData>> combineIngredients(
    List<RecipeModel> recipes) async {
  try {
    var recipesJson =
        jsonEncode(recipes.map((recipe) => recipe.toJson()).toList());

    final result = await FirebaseFunctions.instance
        .httpsCallable('combine_ingredients',
            options:
                HttpsCallableOptions(timeout: const Duration(seconds: 540)))
        .call({'recipes': recipesJson});

    if (result.data['status'] == 'success') {
      // Decode the JSON data
      var decodedData = jsonDecode(result.data['ingredients']);
      print("DECODED $decodedData");

      // Parse the ingredients from the result data
      List<ShoppingListIngredientData> ingredients = (decodedData as List)
          .map((ingredient) => ShoppingListIngredientData.fromJson(ingredient))
          .toList();
      return ingredients;
    } else {
      print('Error: ${result.data['error']}');
      return Future.error(result.data['error']);
    }
  } on FirebaseFunctionsException catch (error) {
    print('Error code: ${error.code}');
    print('Error message: ${error.message}');
    print('Error details: ${error.details}');
    return Future.error(error);
  }
}

Future<RecipeData> extractRecipeDataFromText(String text) async {
  try {
    // Call the function
    final result = await FirebaseFunctions.instance
        .httpsCallable('extract_recipe_from_text',
            options:
                HttpsCallableOptions(timeout: const Duration(seconds: 540)))
        .call({'text': text});

    if (result.data['status'] == 'success') {
      // Bit of a hack that works.
      var recipe = jsonDecode(jsonEncode(result.data))['recipe'];
      return RecipeData.fromJson(recipe.cast<String, dynamic>());
    } else {
      print('Error: ${result.data['error']}');
      return Future.error(result.data['error']);
    }
  } on FirebaseFunctionsException catch (error) {
    print('Error code: ${error.code}');
    print('Error message: ${error.message}');
    print('Error details: ${error.details}');
    return Future.error(error);
  }
}

Future<RecipeData> extractRecipeFromImages(List<String> base64Images) async {
  try {
    // Call the function
    final result = await FirebaseFunctions.instance
        .httpsCallable('extract_recipe_from_images',
            options:
                HttpsCallableOptions(timeout: const Duration(seconds: 540)))
        .call({'images': base64Images});

    RecipeData recipe = await extractRecipeDataFromText(result.data['text']);

    // Return the recipe
    return recipe;
  } on FirebaseFunctionsException catch (error) {
    print('Error code: ${error.code}');
    print('Error message: ${error.message}');
    print('Error details: ${error.details}');
    return Future.error(error);
  }
}

Future<RecipeData> extractRecipeFromWebpage(String url) async {
  try {
    // Call the function
    final result = await FirebaseFunctions.instance
        .httpsCallable('extract_recipe_from_webpage',
            options:
                HttpsCallableOptions(timeout: const Duration(seconds: 540)))
        .call({'url': url});

    developer.log("Result Status: ${result.data['status']}");
    developer.log("Result Data: ${result.data['recipe']}");

    if (result.data['status'] == 'success') {
      var recipe = result.data['recipe'] as Map;
      // Convert the result data to a RecipeModel
      return RecipeData.fromJson(Map<String, dynamic>.from(recipe));
    } else {
      print('Error: ${result.data['error']}');
      return Future.error(result.data['error']);
    }
  } on FirebaseFunctionsException catch (error) {
    print('Error code: ${error.code}');
    print('Error message: ${error.message}');
    print('Error details: ${error.details}');
    return Future.error(error);
  }
}
