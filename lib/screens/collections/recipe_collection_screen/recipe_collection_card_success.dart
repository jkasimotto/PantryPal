// recipe_checkbox.dart
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/providers/ui/nav_provider.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_provider.dart';
import 'package:flutter_recipes/providers/models/recipes/selected_recipes_provider.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_screen.dart';
import 'package:flutter_recipes/shared/keys/global_keys.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

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

class RecipeCollectionSuccessCard extends StatelessWidget {
  final RecipeModel recipe;
  final int index;

  const RecipeCollectionSuccessCard(
      {Key? key, required this.recipe, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NavProvider navProvider = Provider.of<NavProvider>(context);

    return Card(
      key: Key(recipe.id),
      elevation: 5,
      child: RecipeCollectionListTile(
        recipe: recipe,
        leading: index == 0
            ? Showcase(
                key: recipeCollectionCardCheckboxShowcaseKey,
                description: 'Select recipes',
                child: RecipeCollectionCheckbox(recipe: recipe))
            : RecipeCollectionCheckbox(recipe: recipe),
        onTap: navProvider.navigateToRecipeScreen,
      ),
    );
  }
}
