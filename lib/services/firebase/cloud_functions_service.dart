import 'dart:developer' as developer;
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_model.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';

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

Future<RecipeModel> extractRecipeFromText(String text) async {
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
      return RecipeModel.fromJson(recipe.cast<String, dynamic>());
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

Future<RecipeModel> extractRecipeFromImages(List<String> base64Images) async {
  try {
    // Call the function
    final result = await FirebaseFunctions.instance
        .httpsCallable('extract_recipe_from_images',
            options:
                HttpsCallableOptions(timeout: const Duration(seconds: 540)))
        .call({'images': base64Images});

    RecipeModel recipe = await extractRecipeFromText(result.data['text']);

    // Return the recipe
    return recipe;
  } on FirebaseFunctionsException catch (error) {
    print('Error code: ${error.code}');
    print('Error message: ${error.message}');
    print('Error details: ${error.details}');
    return Future.error(error);
  }
}

Future<RecipeModel> extractRecipeFromWebpage(String url) async {
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
      return RecipeModel.fromJson(Map<String, dynamic>.from(recipe));
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
      'add_ingredient_icon_path_to_entity',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 540)),
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'entity_id': recipeId,
        'entity_type': 'recipe',
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
      'add_ingredient_icon_path_to_entity',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 540)),
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'entity_id': listId,
        'entity_type': 'list',
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

Future<IngredientMeta> getIngredientMetadata(String ingredientName) async {
  try {
    // Call the function
    final result = await FirebaseFunctions.instance
        .httpsCallable('get_ingredient_metadata_by_exact_name_match')
        .call({'ingredient_name': ingredientName});

    // Return the ingredient metadata
    return IngredientMeta.fromJson(
        jsonDecode(jsonEncode(result.data['ingredientMeta']))
            as Map<String, dynamic>);
  } on FirebaseFunctionsException catch (error) {
    print('Error code: ${error.code}');
    print('Error message: ${error.message}');
    print('Error details: ${error.details}');
    return Future.error(error);
  }
}
