import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_model.dart';
import 'package:flutter_recipes/models/ingredient/quantity.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_provider.dart';
import 'package:flutter_recipes/providers/models/user/user_provider.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_controller.dart';
import 'package:flutter_recipes/services/business/ad_service.dart';
import 'package:flutter_recipes/services/firebase/firestore_service.dart';
import 'package:flutter_recipes/services/business/recipe_service.dart';
import 'package:flutter_recipes/shared/ingredients/view_ingredient_compact_card.dart';
import 'package:flutter_recipes/shared/ingredients/ingredient_dialog_with_quantity.dart';
import 'package:flutter_recipes/shared/ingredients/add_ingredient_compact_card.dart';
import 'package:flutter_recipes/shared/ingredients/add_ingredient_grid_card.dart';
import 'package:flutter_recipes/shared/ingredients/view_ingredient_grid_card.dart';
import 'package:provider/provider.dart';

enum CurrentView { compact, grid, plainText }

class RecipeDocIngredientView extends StatelessWidget {
  final RecipeModel recipe;
  final RecipeDocController recipeController;
  final CurrentView currentView;

  const RecipeDocIngredientView({
    super.key,
    required this.recipe,
    required this.recipeController,
    required this.currentView,
  });

  @override
  Widget build(BuildContext context) {
    switch (currentView) {
      case CurrentView.compact:
        return _buildCompactView();
      case CurrentView.grid:
        return _buildGridView();
      case CurrentView.plainText:
        return _buildPlainText();
      default:
        return _buildGridView();
    }
  }

  Widget _buildCompactView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipe.ingredients.length + 1,
      itemBuilder: (context, index) {
        if (index == recipe.ingredients.length) {
          return _buildAddIngredientCard(context);
        }
        return GestureDetector(
          onTap: () => _showIngredientDialog(context, index),
          child: ViewIngredientCompactCard(
            ingredient: recipe.ingredients[index],
          ),
        );
      },
    );
  }

  Widget _buildAddIngredientCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showIngredientDialog(context, recipe.ingredients.length,
          isAdding: true),
      child: const AddIngredientCompactCard(),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipe.ingredients.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (context, index) {
        if (index == recipe.ingredients.length) {
          return GestureDetector(
            onTap: () => _showIngredientDialog(
                context, recipe.ingredients.length,
                isAdding: true),
            child: const AddIngredientGridCard(),
          );
        }
        return GestureDetector(
          onTap: () => _showIngredientDialog(context, index),
          child: ViewIngredientGridCard(
            ingredient: recipe.ingredients[index],
          ),
        );
      },
    );
  }

  Widget _buildPlainText() {
    return TextField(
      readOnly: true,
      maxLines: null,
      controller: TextEditingController(
        text: recipe.ingredients
            .map((ingredient) =>
                '${ingredient.quantity.amount} ${ingredient.quantity.units} ${ingredient.name}')
            .join('\n'),
      ),
    );
  }

  void _onDelete(BuildContext context, int index) {
    RecipeService recipeService = RecipeService(
      firestoreService: FirestoreService(),
      userProvider: Provider.of<UserProvider>(context, listen: false),
      adService: Provider.of<AdService>(context, listen: false),
      recipeProvider: Provider.of<RecipeProvider>(context, listen: false),
    );

    // Remove the ingredient from the recipe
    recipeService.removeIngredientFromRecipe(
        recipe.id, recipe.ingredients[index]);

    // Remove the controllers for the ingredient
    recipeController.removeIngredient(index);
  }

  void _addIngredient(BuildContext context, int index, IngredientMeta meta) {
    RecipeService recipeService = RecipeService(
      firestoreService: FirestoreService(),
      userProvider: Provider.of<UserProvider>(context, listen: false),
      adService: Provider.of<AdService>(context, listen: false),
      recipeProvider: Provider.of<RecipeProvider>(context, listen: false),
    );

    // Create a new IngredientWithQuantity
    IngredientWithQuantity newIngredient = IngredientWithQuantity(
      name: recipeController.ingredientNameControllers[index].text,
      meta: meta,
      quantity: Quantity(
        amount: double.parse(
            recipeController.ingredientQuantityControllers[index].text),
        units: recipeController.ingredientUnitControllers[index].text,
      ),
    );

    recipeService.addIngredientToRecipe(recipe.id, newIngredient);

    // Add new controllers for the next new ingredient
    recipeController.addIngredient();
  }

  void _editIngredient(BuildContext context, int index) {
    RecipeService recipeService = RecipeService(
      firestoreService: FirestoreService(),
      userProvider: Provider.of<UserProvider>(context, listen: false),
      adService: Provider.of<AdService>(context, listen: false),
      recipeProvider: Provider.of<RecipeProvider>(context, listen: false),
    );

    IngredientWithQuantity editedIngredient =
        recipe.ingredients[index].copyWith(
      name: recipeController.ingredientNameControllers[index].text,
      quantity: Quantity(
        amount: double.parse(
            recipeController.ingredientQuantityControllers[index].text),
        units: recipeController.ingredientUnitControllers[index].text,
      ),
    );

    recipeService.editIngredientInRecipe(recipe.id, editedIngredient);
  }

  void _onSave(
      BuildContext context, int index, IngredientMeta meta, bool isAdding) {
    if (isAdding) {
      _addIngredient(context, index, meta);
    } else {
      _editIngredient(context, index);
    }
  }

  void _showIngredientDialog(BuildContext context, int index,
      {bool isAdding = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return IngredientDialogWithQuantity(
          title: isAdding ? 'Add Ingredient' : 'Edit Ingredient',
          nameController: recipeController.ingredientNameControllers[index],
          quantityController:
              recipeController.ingredientQuantityControllers[index],
          unitController: recipeController.ingredientUnitControllers[index],
          onDelete: (index) => _onDelete(context, index),
          onSave: (index, IngredientMeta meta) =>
              _onSave(context, index, meta, isAdding),
          index: index,
        );
      },
    );
  }
}
