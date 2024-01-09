import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/models/shopping_list/shopping_list_model.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_provider.dart';
import 'package:flutter_recipes/providers/models/shopping_lists/shopping_list_provider.dart';
import 'package:flutter_recipes/screens/collections/list_collection_screen/shopping_list_collection_screen.dart';
import 'package:flutter_recipes/screens/docs/shopping_list_doc_screen/shopping_list_doc_screen.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_screen.dart';
import 'package:provider/provider.dart';

class NavProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void navigateToScreen(BuildContext context, int index) {
    String routeName;
    switch (index) {
      case 0:
        routeName = '/search';
        break;
      case 1:
        routeName = '/list';
        break;
      case 2:
        routeName = '/account';
        break;
      default:
        routeName = '/';
    }
    _currentIndex = index;
    Navigator.pushReplacementNamed(context, routeName);
  }

  void navigateToListScreen(BuildContext context) {
    _currentIndex = 1;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) =>
              const ShoppingListCollectionScreen()),
      (route) => false,
    );
  }

  void navigateToRecipeScreen(BuildContext context, RecipeModel recipe) {
    Provider.of<RecipeProvider>(context, listen: false).setRecipe(recipe);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDocScreen(recipe: recipe),
      ),
    );
  }

  void navigateToShoppingListScreen(
      BuildContext context, ShoppingList shoppingList) {
    Provider.of<ShoppingListProvider>(context, listen: false)
        .setShoppingList(shoppingList);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShoppingListDocScreen(shoppingList: shoppingList),
      ),
    );
  }
}
