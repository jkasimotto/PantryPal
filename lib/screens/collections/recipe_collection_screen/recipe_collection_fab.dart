// lib/screens/home_screen/recipe_collection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_recipes/providers/ui/ui_provider.dart';
import 'package:flutter_recipes/shared/keys/global_keys.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class RecipeCollectionFAB extends StatelessWidget {
  const RecipeCollectionFAB({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: recipeCollectionFABSearchShowcaseKey,
      description: 'Search and filter recipes here',
      child: Showcase(
        key: recipeCollectionFABAddShowcaseKey,
        description: 'Add new recipes here',
        onTargetClick: () {
          Provider.of<UIProvider>(context, listen: false)
              .toggleAddingOrSearchingRecipes();
        },
        onBarrierClick: () {
          Provider.of<UIProvider>(context, listen: false)
              .toggleAddingOrSearchingRecipes();
        },
        disposeOnTap: false,
        child: FloatingActionButton(
          onPressed: () {
            Provider.of<UIProvider>(context, listen: false)
                .toggleAddingOrSearchingRecipes();
          },
          child: Provider.of<UIProvider>(context).isAddingOrSearchingRecipes
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FaIcon(FontAwesomeIcons.magnifyingGlass),
                    Text(
                      'Search',
                      style: TextStyle(fontSize: 10.0),
                    ),
                  ],
                )
              : const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FaIcon(FontAwesomeIcons.plus),
                    Text('Add', style: TextStyle(fontSize: 10.0)),
                  ],
                ),
        ),
      ),
    );
  }
}
