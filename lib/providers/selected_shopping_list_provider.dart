import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/shopping_list/shopping_list_model.dart';

class SelectedShoppingListProvider extends ChangeNotifier {
  final Map<String, ShoppingList> _selectedLists = {};

  Map<String, ShoppingList> get selectedLists => _selectedLists;

  void updateSelectedLists(String id, bool value, ShoppingList list) {
    if (value == true) {
      _selectedLists[id] = list;
    } else {
      _selectedLists.remove(id);
    }
    notifyListeners();
  }

  void clearSelectedLists() {
    _selectedLists.clear();
    notifyListeners();
  }
}
