import 'package:flutter/material.dart';

class RecipeFilterProvider extends ChangeNotifier {
  String _searchQuery = '';
  int _minutesRequired = 180;

  String get searchQuery => _searchQuery;
  int get minutesRequired => _minutesRequired;

  void setSearchQuery(String newQuery) {
    _searchQuery = newQuery;
    notifyListeners();
  }

  void setMinutesRequired(int newMinutesRequired) {
    _minutesRequired = newMinutesRequired;
    notifyListeners();
  }
}
