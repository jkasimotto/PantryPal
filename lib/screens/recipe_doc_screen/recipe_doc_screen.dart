import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/ingredient/ingredient.dart';
import 'package:flutter_recipes/models/ingredient/nutritional_information.dart';
import 'package:flutter_recipes/models/ingredient/quantity.dart';
import 'package:flutter_recipes/models/method/recipe_method_step_model.dart';
import 'package:flutter_recipes/models/recipe/recipe.dart';
import 'package:flutter_recipes/screens/recipe_screen/app_bar.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/ingredient_list_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/method_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/notes_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/servings_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/timer_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/cuisine_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/title_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/recipe_controller.dart';
import 'package:flutter_recipes/services/firestore_service.dart';

class RecipeDocScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDocScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RecipeDocScreenState createState() => _RecipeDocScreenState();
}

class _RecipeDocScreenState extends State<RecipeDocScreen> {
  final _firestoreService = FirestoreService();
  late RecipeController _recipeController;
  late List<IngredientWithQuantity> _ingredients;
  late List<RecipeMethodStepData> _methodSteps;

  @override
  void initState() {
    super.initState();
    _recipeController = RecipeController(widget.recipe);
    _ingredients = widget.recipe.ingredients;
    _methodSteps = widget.recipe.method;
  }

  @override
  void dispose() {
    _recipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RecipeScreenAppBar(_saveRecipe),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            buildRecipeDocTitleCard(),
            buildRecipeDocTimerCard(),
            buildRecipeDocCuisineCard(),
            buildRecipeDocServingsCard(),
            buildRecipeDocIngredientListCard(),
            buildRecipeDocMethodListCard(),
            buildRecipeDocNotesCard(),
          ],
        ),
      ),
    );
  }

  Widget buildRecipeDocTitleCard() {
    return RecipeDocTitleCard(
      titleController: _recipeController.titleController,
    );
  }

  Widget buildRecipeDocTimerCard() {
    return RecipeDocTimerCard(
      prepTimeController: _recipeController.prepTimeController,
      cookTimeController: _recipeController.cookTimeController,
    );
  }

  Widget buildRecipeDocCuisineCard() {
    return RecipeDocCuisineCard(
      cuisineController: _recipeController.cuisineController,
      courseController: _recipeController.courseController,
    );
  }

  Widget buildRecipeDocServingsCard() {
    return RecipeDocServingsCard(
      servingsController: _recipeController.servingsController,
    );
  }

  Widget buildRecipeDocIngredientListCard() {
    return RecipeDocIngredientListCard(
      ingredients: _ingredients,
      recipeController: _recipeController,
      onIngredientSave: _onIngredientSave,
      saveRecipe: _saveRecipe,
    );
  }

  Widget buildRecipeDocMethodListCard() {
    return RecipeDocMethodListCard(
      methodSteps: _methodSteps,
      methodControllers: _recipeController.methodControllers,
    );
  }

  Widget buildRecipeDocNotesCard() {
    return RecipeDocNotesCard(
      notesController: _recipeController.notesController,
    );
  }

  void _onIngredientSave(int index) {
    setState(() {
      updateExistingIngredient(index);
      addNewIngredient(index);
    });

    saveRecipeAndCloseDialog();
  }

  void updateExistingIngredient(int index) {
    if (index < _ingredients.length) {
      _ingredients[index] = _ingredients[index].copyWith(
        name: _recipeController.ingredientNameControllers[index].text,
        quantity: Quantity(
          amount: double.tryParse(_recipeController
                  .ingredientQuantityControllers[index].text) ??
              0,
          units: _recipeController.ingredientUnitControllers[index].text,
        ),
      );
    }
  }

  void addNewIngredient(int index) {
    if (index == _recipeController.ingredientNameControllers.length - 1) {
      _ingredients.add(IngredientWithQuantity(
        name: _recipeController.ingredientNameControllers[index].text,
        meta: IngredientMeta(),
        quantity: Quantity(
          amount: double.tryParse(_recipeController
                  .ingredientQuantityControllers[index].text) ??
              0,
          units: _recipeController.ingredientUnitControllers[index].text,
        ),
      ));

      _recipeController.ingredientNameControllers.add(TextEditingController());
      _recipeController.ingredientQuantityControllers
          .add(TextEditingController());
      _recipeController.ingredientUnitControllers.add(TextEditingController());
    }
  }

  void saveRecipeAndCloseDialog() {
    _saveRecipe(shouldShowDialog: false);
    Navigator.of(context).pop();
  }

  void _saveRecipe({bool shouldShowDialog = true}) {
    Recipe updatedRecipe = updateRecipe();

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

  Recipe updateRecipe() {
    return widget.recipe.copyWith(
      title: _recipeController.titleController.text,
      ingredients: _ingredients,
      method: _methodSteps,
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
