import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe_model.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:flutter_recipes/screens/home_screen/loading_recipe_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/recipe_screen.dart';
import 'package:flutter_recipes/services/firestore_service.dart';
import 'package:provider/provider.dart';

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final Function onChanged;

  RecipeCard({super.key, required this.recipe, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    switch (recipe.metadata.status) {
      case Status.loading:
        // Display a loading card
        return LoadingRecipeCard(recipe: recipe);
      case Status.success:
        // Display the regular card
        return Card(
          key: Key(recipe.id),
          elevation: 5,
          child: ListTile(
            leading: Checkbox(
              value: Provider.of<GlobalState>(context)
                  .selectedRecipes
                  .containsKey(recipe.id),
              onChanged: (bool? value) {
                onChanged(value);
              },
            ),
            title: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeScreen(recipe: recipe),
                  ),
                );
              },
              child: Text(recipe.data.title),
            ),
          ),
        );
      case Status.error:
  // Display an error message
  return Card(
    color: Colors.red,
    child: ListTile(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () async {
          FirestoreService firestoreService = FirestoreService();
          await firestoreService.deleteDocument(recipe.id, 'recipes');
        },
      ),
      title: const Text('An error occurred while loading the recipe.'),
    ),
  );
    }
  }
}
