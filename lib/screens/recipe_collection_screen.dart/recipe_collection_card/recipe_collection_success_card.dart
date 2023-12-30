// recipe_checkbox.dart
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/providers/selected_recipes_provider.dart';
import 'package:flutter_recipes/screens/recipe_doc_screen/recipe_doc_screen.dart';
import 'package:provider/provider.dart';

class RecipeCollectionCheckbox extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeCollectionCheckbox({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SelectedRecipeProvider selectedRecipeProvider =
        Provider.of<SelectedRecipeProvider>(context);
    return Checkbox(
        value: selectedRecipeProvider.selectedRecipes.containsKey(recipe.id),
        onChanged: (value) => selectedRecipeProvider.updateSelectedRecipes(
            recipe.id, value ?? false, recipe));
  }
}

class RecipeCollectionListTile extends StatelessWidget {
  final RecipeModel recipe;
  final Widget leading;
  final Function(BuildContext, RecipeModel) onTap;

  const RecipeCollectionListTile({
    Key? key,
    required this.recipe,
    required this.leading,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: InkWell(
        onTap: () => onTap(context, recipe),
        child: Text(recipe.title),
      ),
    );
  }
}

class NavigationService {
  void navigateToRecipeScreen(BuildContext context, RecipeModel recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDocScreen(recipe: recipe),
      ),
    );
  }
}

class RecipeCollectionSuccessCard extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeCollectionSuccessCard({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key(recipe.id),
      elevation: 5,
      child: RecipeCollectionListTile(
        recipe: recipe,
        leading: RecipeCollectionCheckbox(recipe: recipe),
        onTap: NavigationService().navigateToRecipeScreen,
      ),
    );
  }
}
