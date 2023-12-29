// lib/default_recipes/bacon_and_eggs_recipe.dart

import 'package:flutter_recipes/models/ingredient/quantity.dart';
import 'package:flutter_recipes/models/recipe/recipe.dart';
import 'package:flutter_recipes/models/ingredient/ingredient.dart';
import 'package:flutter_recipes/models/method/recipe_method_step_model.dart';
import 'package:flutter_recipes/models/status.dart';

Recipe getBaconAndEggsRecipe() {
  return Recipe(
    title: 'Bacon and Eggs',
    ingredients: [
      IngredientWithQuantity(
        name: 'Bacon',
        quantity: Quantity(amount: 2, units: 'slices'),
        meta: IngredientMeta(ingredientId: 'v0ZZh6lAk9JElQHHy8rK'),
      ),
      IngredientWithQuantity(
        name: 'Eggs',
        quantity: Quantity(amount: 2, units: 'pieces'),
        meta: IngredientMeta(ingredientId: 'fiW0T6ct6e1AD6pV4rtv'),
      ),
    ],
    method: [
      RecipeMethodStepData(
        stepNumber: 1,
        description: 'Cook the bacon in a hot pan until crispy.',
      ),
      RecipeMethodStepData(
        stepNumber: 2,
        description: 'Fry the eggs in the bacon grease to your liking.',
      ),
    ],
    cuisine: 'American',
    course: 'Breakfast',
    servings: 1,
    prepTime: 5,
    cookTime: 10,
    meta: RecipeMetadata(source: RecipeSource.text, status: Status.success),
  );
}

Recipe getSoftBoiledEggRecipe() {
  return Recipe(
    title: 'Soft Boiled Egg',
    ingredients: [
      IngredientWithQuantity(
        name: 'Egg',
        quantity: Quantity(amount: 1, units: 'piece'),
        meta: IngredientMeta(ingredientId: 'fiW0T6ct6e1AD6pV4rtv'),
      ),
    ],
    method: [
      RecipeMethodStepData(
        stepNumber: 1,
        description: 'Place the egg in a pot of boiling water.',
      ),
      RecipeMethodStepData(
        stepNumber: 2,
        description: 'Boil for 4-5 minutes for a runny yolk.',
      ),
      RecipeMethodStepData(
        stepNumber: 3,
        description:
            'Remove the egg and place it in cold water to stop the cooking process.',
      ),
    ],
    cuisine: 'International',
    course: 'Breakfast',
    servings: 1,
    prepTime: 1,
    cookTime: 5,
    meta: RecipeMetadata(source: RecipeSource.text, status: Status.success),
  );
}
