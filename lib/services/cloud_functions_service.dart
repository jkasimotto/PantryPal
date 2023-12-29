import 'dart:developer' as developer;
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_recipes/models/ingredient/ingredient.dart';
import 'package:flutter_recipes/models/recipe/recipe.dart';
import 'package:flutter_recipes/models/status.dart';

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

Future<List<ShoppingListIngredient>> combineIngredients(
    List<Recipe> recipes) async {
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
      List<ShoppingListIngredient> ingredients = (decodedData as List)
          .map((ingredient) => ShoppingListIngredient.fromJson(ingredient))
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

Future<Recipe> extractRecipeFromText(String text) async {
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
      return Recipe.fromJson(recipe.cast<String, dynamic>());
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

Future<Recipe> extractRecipeFromImages(List<String> base64Images) async {
  try {
    // Call the function
    final result = await FirebaseFunctions.instance
        .httpsCallable('extract_recipe_from_images',
            options:
                HttpsCallableOptions(timeout: const Duration(seconds: 540)))
        .call({'images': base64Images});

    Recipe recipe = await extractRecipeFromText(result.data['text']);

    // Return the recipe
    return recipe;
  } on FirebaseFunctionsException catch (error) {
    print('Error code: ${error.code}');
    print('Error message: ${error.message}');
    print('Error details: ${error.details}');
    return Future.error(error);
  }
}

Future<Recipe> extractRecipeFromWebpage(String url) async {
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
      // Convert the result data to a Recipe
      return Recipe.fromJson(Map<String, dynamic>.from(recipe));
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

Future<Map<String, dynamic>> addIngredientIconPathToRecipe(
    String recipeId) async {
  try {
    // Call the function
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'add_ingredient_icon_path_to_recipe',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 540)),
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'recipe_id': recipeId,
      },
    );

    // Return the result
    return result.data as Map<String, dynamic>;
  } on FirebaseFunctionsException catch (error) {
    print('Error code: ${error.code}');
    print('Error message: ${error.message}');
    print('Error details: ${error.details}');
    return Future.error(error);
  }
}

Future<Map<String, dynamic>> addIngredientIconPathToList(String listId) async {
  try {
    // Call the function
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'add_ingredient_icon_path_to_list',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 540)),
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'list_id': listId,
      },
    );

    // Return the result
    return result.data as Map<String, dynamic>;
  } on FirebaseFunctionsException catch (error) {
    print('Error code: ${error.code}');
    print('Error message: ${error.message}');
    print('Error details: ${error.details}');
    return Future.error(error);
  }
}
