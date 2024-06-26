import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/services/firebase/firestore_service.dart';

class RecipeCollectionErrorCard extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeCollectionErrorCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red,
      child: ListTile(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _deleteRecipe(context, recipe.id),
        ),
        title: const Text('An error occurred while loading the recipe.'),
      ),
    );
  }

  Future<void> _deleteRecipe(BuildContext context, String recipeId) async {
    FirestoreService firestoreService = FirestoreService();
    await firestoreService.deleteDocument(recipeId, 'recipes');
  }
}
