// recipe_checkbox.dart
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe.dart';
import 'package:flutter_recipes/screens/recipe_doc_screen/recipe_doc_screen.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:provider/provider.dart';

class RecipeCollectionCheckbox extends StatelessWidget {
  final String recipeId;
  final Function(bool?) onChanged;

  const RecipeCollectionCheckbox({
    Key? key,
    required this.recipeId,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: Provider.of<GlobalState>(context)
          .selectedRecipes
          .containsKey(recipeId),
      onChanged: onChanged,
    );
  }
}

class RecipeCollectionListTile extends StatelessWidget {
  final Recipe recipe;
  final Widget leading;
  final Function(BuildContext, Recipe) onTap;

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
  void navigateToRecipeScreen(BuildContext context, Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDocScreen(recipe: recipe),
      ),
    );
  }
}

class RecipeCollectionSuccessCard extends StatelessWidget {
  final Recipe recipe;
  final Function(bool?) onChanged;

  const RecipeCollectionSuccessCard({
    Key? key,
    required this.recipe,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key(recipe.id),
      elevation: 5,
      child: RecipeCollectionListTile(
        recipe: recipe,
        leading:
            RecipeCollectionCheckbox(recipeId: recipe.id, onChanged: onChanged),
        onTap: NavigationService().navigateToRecipeScreen,
      ),
    );
  }
}
