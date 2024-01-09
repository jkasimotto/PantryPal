import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/method/recipe_method_step_model.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_provider.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_app_bar.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_card_ingredients.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_card_method.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_card_notes.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_card_servings.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_card_time.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_card_cuisine.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_card_title.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_controller.dart';
import 'package:flutter_recipes/services/firebase/firestore_service.dart';
import 'package:provider/provider.dart';

class RecipeDocScreen extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeDocScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RecipeDocScreenState createState() => _RecipeDocScreenState();
}

class _RecipeDocScreenState extends State<RecipeDocScreen> {
  final _firestoreService = FirestoreService();
  late RecipeDocController _recipeController;
  late List<RecipeMethodStepData> _methodSteps;
  late ValueNotifier<RecipeModel> _recipeNotifier;

  @override
  void initState() {
    super.initState();
    _recipeController = RecipeDocController(widget.recipe);
    _methodSteps = widget.recipe.method;
    _recipeNotifier =
        Provider.of<RecipeProvider>(context, listen: false).recipeNotifier;
  }

  @override
  void dispose() {
    _recipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _recipeNotifier,
        builder:
            (BuildContext context, RecipeModel updatedRecipe, Widget? child) {
          return Scaffold(
            appBar: RecipeDocAppBar(_saveRecipe),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  buildRecipeDocTitleCard(updatedRecipe),
                  buildRecipeDocCuisineCard(updatedRecipe),
                  buildRecipeDocTimerCard(updatedRecipe),
                  buildRecipeDocServingsCard(updatedRecipe),
                  buildRecipeDocIngredientListCard(updatedRecipe),
                  buildRecipeDocMethodListCard(updatedRecipe),
                  buildRecipeDocNotesCard(updatedRecipe),
                ],
              ),
            ),
          );
        });
  }

  Widget buildRecipeDocTitleCard(RecipeModel updatedRecipe) {
    return RecipeDocCardTitle(
      titleController: _recipeController.titleController,
    );
  }

  Widget buildRecipeDocTimerCard(RecipeModel updatedRecipe) {
    return RecipeDocCardTime(
      prepTimeController: _recipeController.prepTimeController,
      cookTimeController: _recipeController.cookTimeController,
    );
  }

  Widget buildRecipeDocCuisineCard(RecipeModel updatedRecipe) {
    return RecipeDocCardCuisine(
      cuisineController: _recipeController.cuisineController,
      courseController: _recipeController.courseController,
    );
  }

  Widget buildRecipeDocServingsCard(RecipeModel updatedRecipe) {
    return RecipeDocCardServings(
      servingsController: _recipeController.servingsController,
    );
  }

  Widget buildRecipeDocIngredientListCard(RecipeModel updatedRecipe) {
    return RecipeDocCardIngredients(
      recipe: updatedRecipe,
      recipeController: _recipeController,
      saveRecipe: _saveRecipe,
    );
  }

  Widget buildRecipeDocMethodListCard(RecipeModel updatedRecipe) {
    return RecipeDocCardMethod(
      methodSteps: _methodSteps,
      methodControllers: _recipeController.methodControllers,
    );
  }

  Widget buildRecipeDocNotesCard(RecipeModel updatedRecipe) {
    return RecipeDocCardNotes(
      notesController: _recipeController.notesController,
    );
  }

  void saveRecipeAndCloseDialog() {
    _saveRecipe(shouldShowDialog: false);
    Navigator.of(context).pop();
  }

  void _saveRecipe({bool shouldShowDialog = true}) {
    RecipeModel updatedRecipe = updateRecipe();

    _firestoreService.updateDocument(updatedRecipe, 'recipes').then((_) {
      if (kDebugMode) {
        print('Recipe updated in Firestore');
      }
      if (shouldShowDialog) {
        showSuccessDialog();
      }
    }).catchError((error) {
      handleError(error);
    });
  }

  RecipeModel updateRecipe() {
    return widget.recipe.copyWith(
      title: _recipeController.titleController.text,
      cuisine: _recipeController.cuisineController.text,
      course: _recipeController.courseController.text,
      servings: int.parse(_recipeController.servingsController.text),
      prepTime: int.parse(_recipeController.prepTimeController.text),
      cookTime: int.parse(_recipeController.cookTimeController.text),
      notes: _recipeController.notesController.text,
    );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Recipe updated successfully'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void handleError(error) {
    if (kDebugMode) {
      print('Failed to update recipe: $error');
    }
    return null;
  }
}
