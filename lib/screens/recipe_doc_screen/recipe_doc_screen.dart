import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/method/recipe_method_step_model.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/screens/recipe_screen/app_bar.dart';
import 'package:flutter_recipes/screens/recipe_doc_screen/recipe_doc_ingredient_view_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/method_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/notes_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/servings_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/timer_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/cuisine_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/title_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/recipe_controller.dart';
import 'package:flutter_recipes/services/firestore_service.dart';

class RecipeDocScreen extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeDocScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RecipeDocScreenState createState() => _RecipeDocScreenState();
}

class _RecipeDocScreenState extends State<RecipeDocScreen> {
  final _firestoreService = FirestoreService();
  late RecipeController _recipeController;
  late List<RecipeMethodStepData> _methodSteps;

  @override
  void initState() {
    super.initState();
    _recipeController = RecipeController(widget.recipe);
    _methodSteps = widget.recipe.method;
  }

  @override
  void dispose() {
    _recipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestoreService.listenToRecipe(widget.recipe.id),
        builder: (BuildContext context, AsyncSnapshot<RecipeModel> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          RecipeModel updatedRecipe = snapshot.data!;

          return Scaffold(
            appBar: RecipeScreenAppBar(_saveRecipe),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  buildRecipeDocTitleCard(updatedRecipe),
                  buildRecipeDocTimerCard(updatedRecipe),
                  buildRecipeDocCuisineCard(updatedRecipe),
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
    return RecipeDocTitleCard(
      titleController: _recipeController.titleController,
    );
  }

  Widget buildRecipeDocTimerCard(RecipeModel updatedRecipe) {
    return RecipeDocTimerCard(
      prepTimeController: _recipeController.prepTimeController,
      cookTimeController: _recipeController.cookTimeController,
    );
  }

  Widget buildRecipeDocCuisineCard(RecipeModel updatedRecipe) {
    return RecipeDocCuisineCard(
      cuisineController: _recipeController.cuisineController,
      courseController: _recipeController.courseController,
    );
  }

  Widget buildRecipeDocServingsCard(RecipeModel updatedRecipe) {
    return RecipeDocServingsCard(
      servingsController: _recipeController.servingsController,
    );
  }

  Widget buildRecipeDocIngredientListCard(RecipeModel updatedRecipe) {
    return RecipeDocIngredientViewCard(
      recipe: updatedRecipe,
      recipeController: _recipeController,
      saveRecipe: _saveRecipe,
    );
  }

  Widget buildRecipeDocMethodListCard(RecipeModel updatedRecipe) {
    return RecipeDocMethodListCard(
      methodSteps: _methodSteps,
      methodControllers: _recipeController.methodControllers,
    );
  }

  Widget buildRecipeDocNotesCard(RecipeModel updatedRecipe) {
    return RecipeDocNotesCard(
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
