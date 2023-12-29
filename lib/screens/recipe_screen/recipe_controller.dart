import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe.dart';

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

  RecipeController(Recipe recipe) {
    titleController = TextEditingController(text: recipe.title);
    ingredientsController =
        TextEditingController(text: recipe.ingredients.join('\n'));
    methodController = TextEditingController(text: recipe.method.join('\n'));
    timeRequiredController =
        TextEditingController(text: recipe.totalTime.toString());
    cuisineController = TextEditingController(text: recipe.cuisine);
    courseController = TextEditingController(text: recipe.course);
    servingsController =
        TextEditingController(text: recipe.servings.toString());
    prepTimeController =
        TextEditingController(text: recipe.prepTime.toString());
    cookTimeController =
        TextEditingController(text: recipe.cookTime.toString());
    notesController = TextEditingController(text: recipe.notes ?? '');

    ingredientNameControllers = List.generate(
      recipe.ingredients.length,
      (index) => TextEditingController(text: recipe.ingredients[index].name),
    );
    ingredientQuantityControllers = List.generate(
      recipe.ingredients.length,
      (index) => TextEditingController(
          text: recipe.ingredients[index].quantity.amount.toString()),
    );
    ingredientUnitControllers = List.generate(
      recipe.ingredients.length,
      (index) => TextEditingController(
          text: recipe.ingredients[index].quantity.units.toString()),
    );

    methodControllers = List.generate(
      recipe.method.length,
      (index) => [
        TextEditingController(text: recipe.method[index].stepNumber.toString()),
        TextEditingController(text: recipe.method[index].description),
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
