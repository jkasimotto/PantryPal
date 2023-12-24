import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';

class RecipeController {
  late TextEditingController titleController;
  late TextEditingController ingredientsController;
  late TextEditingController methodController;
  late TextEditingController timeRequiredController;
  late TextEditingController cuisineController;
  late TextEditingController courseController;
  late TextEditingController servingsController;
  late TextEditingController prepTimeController;
  late TextEditingController cookTimeController;
  late TextEditingController notesController;

  List<TextEditingController> ingredientNameControllers = [];
  List<TextEditingController> ingredientQuantityControllers = [];
  List<TextEditingController> ingredientUnitControllers = [];

  List<List<TextEditingController>> methodControllers = [];

  RecipeController(RecipeModel recipe) {
    titleController = TextEditingController(text: recipe.data.title);
    ingredientsController =
        TextEditingController(text: recipe.data.ingredients.join('\n'));
    methodController =
        TextEditingController(text: recipe.data.method.join('\n'));
    timeRequiredController =
        TextEditingController(text: recipe.data.totalTime.toString());
    cuisineController = TextEditingController(text: recipe.data.cuisine);
    courseController = TextEditingController(text: recipe.data.course);
    servingsController =
        TextEditingController(text: recipe.data.servings.toString());
    prepTimeController =
        TextEditingController(text: recipe.data.prepTime.toString());
    cookTimeController =
        TextEditingController(text: recipe.data.cookTime.toString());
    notesController = TextEditingController(text: recipe.data.notes ?? '');

    ingredientNameControllers = List.generate(
      recipe.data.ingredients.length,
      (index) => TextEditingController(
          text: recipe.data.ingredients[index].ingredientData.name),
    );
    ingredientQuantityControllers = List.generate(
      recipe.data.ingredients.length,
      (index) => TextEditingController(
          text: recipe.data.ingredients[index].quantity.toString()),
    );
    ingredientUnitControllers = List.generate(
      recipe.data.ingredients.length,
      (index) => TextEditingController(
          text: recipe.data.ingredients[index].units.toString()),
    );

    methodControllers = List.generate(
      recipe.data.method.length,
      (index) => [
        TextEditingController(
            text: recipe.data.method[index].stepNumber.toString()),
        TextEditingController(text: recipe.data.method[index].description),
        // Add more controllers for each field in RecipeMethodStepData
      ],
    );

    // Add controllers for the unadded recipe
    ingredientNameControllers.add(TextEditingController());
    ingredientQuantityControllers.add(TextEditingController());
    ingredientUnitControllers.add(TextEditingController());
  }

  void dispose() {
    titleController.dispose();
    ingredientsController.dispose();
    methodController.dispose();
    timeRequiredController.dispose();
    cuisineController.dispose();
    courseController.dispose();
    servingsController.dispose();
    prepTimeController.dispose();
    cookTimeController.dispose();
    notesController.dispose();

    for (var controller in ingredientNameControllers) {
      controller.dispose();
    }
    for (var controller in ingredientQuantityControllers) {
      controller.dispose();
    }
    for (var controller in ingredientUnitControllers) {
      controller.dispose();
    }

    for (var controllers in methodControllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
  }
}
