// lib/screens/home_screen/recipe_collection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class RecipeCollectionFAB extends StatelessWidget {
  const RecipeCollectionFAB({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Provider.of<GlobalState>(context, listen: false)
            .setAddingOrSearchingRecipes(
                !Provider.of<GlobalState>(context, listen: false)
                    .isAddingOrSearchingRecipes);
      },
      child: Provider.of<GlobalState>(context).isAddingOrSearchingRecipes
          ? const FaIcon(FontAwesomeIcons.magnifyingGlass)
          : const FaIcon(FontAwesomeIcons.plus),
    );
  }
}
