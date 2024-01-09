import 'package:flutter/material.dart';

class UIProvider extends ChangeNotifier {
  bool _isBottomSheetVisible = true;
  bool _isAddingOrSearchingRecipes = false;

  bool get isBottomSheetVisible => _isBottomSheetVisible;
  bool get isAddingOrSearchingRecipes => _isAddingOrSearchingRecipes;

  void toggleBottomSheetVisibility() {
    _isBottomSheetVisible = !_isBottomSheetVisible;
    notifyListeners();
  }

  void setAddingOrSearchingRecipes(bool value) {
    _isAddingOrSearchingRecipes = value;
    notifyListeners();
  }

  void toggleAddingOrSearchingRecipes() {
    _isAddingOrSearchingRecipes = !_isAddingOrSearchingRecipes;
    notifyListeners();
  }
}
