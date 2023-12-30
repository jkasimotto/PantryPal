import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_model.dart';
import 'package:flutter_recipes/models/ingredient/quantity.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/providers/recipe_provider.dart';
import 'package:flutter_recipes/providers/user_provider.dart';
import 'package:flutter_recipes/screens/recipe_screen/recipe_controller.dart';
import 'package:flutter_recipes/services/ad_service.dart';
import 'package:flutter_recipes/services/firestore_service.dart';
import 'package:flutter_recipes/services/recipe_service.dart';
import 'package:flutter_recipes/shared/grid_ingredient_card.dart';
import 'package:flutter_recipes/shared/compact_ingredient_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/ingredient_dialog.dart';
import 'package:flutter_recipes/shared/ingredients/compact_add_ingredient_card.dart';
import 'package:flutter_recipes/shared/ingredients/grid_add_ingredient_card.dart';
import 'package:provider/provider.dart';

enum CurrentView { compact, grid, plainText }

class RecipeDocIngredientView extends StatelessWidget {
  final RecipeModel recipe;
  final RecipeController recipeController;
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
          child: CompactIngredientCard(
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
      child: const CompactAddIngredientCard(),
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
            child: const GridAddIngredientCard(),
          );
        }
        return GestureDetector(
          onTap: () => _showIngredientDialog(context, index),
          child: GridIngredientCard(
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

  void _showIngredientDialog(BuildContext context, int index,
      {bool isAdding = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        RecipeService recipeService = RecipeService(
          firestoreService: FirestoreService(),
          userProvider: Provider.of<UserProvider>(context, listen: false),
          adService: Provider.of<AdService>(context, listen: false),
          recipeProvider: Provider.of<RecipeProvider>(context, listen: false),
        );

        return IngredientDialog(
          title: isAdding ? 'Add Ingredient' : 'Edit Ingredient',
          nameController: recipeController.ingredientNameControllers[index],
          quantityController:
              recipeController.ingredientQuantityControllers[index],
          unitController: recipeController.ingredientUnitControllers[index],
          onDelete: (index) {
            // Remove the ingredient from the recipe
            recipeService.removeIngredientFromRecipe(
                recipe.id, recipe.ingredients[index]);

            // Remove the controllers for the ingredient
            recipeController.removeIngredient(index);

            // Remove the ingredient from the list
            recipe.ingredients.removeAt(index);
          },
          onSave: (index, IngredientMeta meta) {
            if (isAdding) {
              // Add new controllers for the new ingredient
              recipeController.addIngredient();

              // Create a new IngredientWithQuantity
              IngredientWithQuantity newIngredient = IngredientWithQuantity(
                name: recipeController.ingredientNameControllers[index].text,
                meta:
                    meta, // We have potentially got metadata but recipe service will add metadata if it's not there
                quantity: Quantity(
                  amount: double.parse(recipeController
                      .ingredientQuantityControllers[index].text),
                  units: recipeController.ingredientUnitControllers[index].text,
                ),
              );
              // Add the new ingredient to the list
              recipe.ingredients.add(newIngredient);

              recipeService.addIngredientToRecipe(
                  recipe.id, recipe.ingredients[index]);
            } else {
              IngredientWithQuantity editedIngredient =
                  recipe.ingredients[index].copyWith(
                name: recipeController.ingredientNameControllers[index].text,
                quantity: Quantity(
                  amount: double.parse(recipeController
                      .ingredientQuantityControllers[index].text),
                  units: recipeController.ingredientUnitControllers[index].text,
                ),
              );

              recipeService.editIngredientInRecipe(recipe.id, editedIngredient);
            }
          },
          index: index,
        );
      },
    );
  }
}
