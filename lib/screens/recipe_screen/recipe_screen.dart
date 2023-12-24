import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_data.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_with_quantity.dart';
import 'package:flutter_recipes/models/ingredient/nutritional_information.dart';
import 'package:flutter_recipes/models/method/recipe_method_step_model.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/screens/recipe_screen/app_bar.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/ingredient_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/method_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/notes_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/servings_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/timer_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/cuisine_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/title_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/recipe_controller.dart';
import 'package:flutter_recipes/services/firestore_service.dart';

class RecipeScreen extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final _firestoreService = FirestoreService();
  late RecipeController _recipeController;
  late List<IngredientWithQuantity> _ingredients;
  late List<RecipeMethodStepData> _methodSteps;

  @override
  void initState() {
    super.initState();
    _recipeController = RecipeController(widget.recipe);
    _ingredients = widget.recipe.data.ingredients;
    _methodSteps = widget.recipe.data.method;
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
            TitleInfoCard(titleController: _recipeController.titleController),
            TimerInfoCard(
                prepTimeController: _recipeController.prepTimeController,
                cookTimeController: _recipeController.cookTimeController),
            CuisineInfoCard(
                cuisineController: _recipeController.cuisineController,
                courseController: _recipeController.courseController),
            ServingsInfoCard(
                servingsController: _recipeController.servingsController),
            IngredientGridCard(
              ingredients: _ingredients,
              recipeController: _recipeController,
              onIngredientSave: _onIngredientSave,
              saveRecipe: _saveRecipe,
            ),
            MethodInfoCard(
                methodSteps: _methodSteps,
                methodControllers: _recipeController.methodControllers),
            NotesInfoCard(notesController: _recipeController.notesController),
          ],
        ),
      ),
    );
  }

  void _onIngredientSave(int index) {
    setState(() {
      // Update the existing ingredient data with the new values from the controllers
      if (index < _ingredients.length) {
        _ingredients[index] = IngredientWithQuantity(
          ingredientData: IngredientData(
            name: _recipeController.ingredientNameControllers[index].text,
            form: _ingredients[index].ingredientData.form,
            category: _ingredients[index].ingredientData.category,
            nutritionalInformation:
                _ingredients[index].ingredientData.nutritionalInformation,
            shelfLife: _ingredients[index].ingredientData.shelfLife,
          ),
          units: _recipeController.ingredientUnitControllers[index].text,
          quantity: double.tryParse(_recipeController
                  .ingredientQuantityControllers[index].text) ??
              0,
        );
      }

      // If this is the last index, add a new ingredient and add new controllers
      if (index == _recipeController.ingredientNameControllers.length - 1) {
        _ingredients.add(IngredientWithQuantity(
          ingredientData: IngredientData(
            name: _recipeController.ingredientNameControllers[index].text,
            form: '',
            category: '',
            nutritionalInformation: NutritionalInformation(
                calories: -1,
                fats: -1,
                carbohydrates: -1,
                proteins: -1,
                vitamins: -1,
                minerals: -1),
            shelfLife: '',
          ),
          units: _recipeController.ingredientUnitControllers[index].text,
          quantity: double.tryParse(_recipeController
                  .ingredientQuantityControllers[index].text) ??
              0,
        ));

        _recipeController.ingredientNameControllers
            .add(TextEditingController());
        _recipeController.ingredientQuantityControllers
            .add(TextEditingController());
        _recipeController.ingredientUnitControllers
            .add(TextEditingController());
      }
    });

    _saveRecipe(shouldShowDialog: false);
    Navigator.of(context).pop();
  }

  void _saveRecipe({bool shouldShowDialog = true}) {
    RecipeModel updatedRecipe = RecipeModel(
      data: RecipeData(
        title: _recipeController.titleController.text,
        ingredients: _ingredients,
        method: _methodSteps,
        cuisine: _recipeController.cuisineController.text,
        course: _recipeController.courseController.text,
        servings: int.parse(_recipeController.servingsController.text),
        prepTime: int.parse(_recipeController.prepTimeController.text),
        cookTime: int.parse(_recipeController.cookTimeController.text),
        notes: _recipeController.notesController.text,
      ),
      metadata: widget.recipe.metadata,
    );

    _firestoreService.updateDocument(updatedRecipe, 'recipes').then((_) {
      if (kDebugMode) {
        print('Recipe updated in Firestore');
      }
      if (shouldShowDialog) {
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
    }).catchError((error) {
      if (kDebugMode) {
        print('Failed to update recipe: $error');
      }
      return null;
    });
  }
}
