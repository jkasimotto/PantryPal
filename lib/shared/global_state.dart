import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/models/shopping_list/shopping_list_model.dart'; // Added this import
import 'package:flutter_recipes/providers/user_provider.dart';
import 'package:flutter_recipes/screens/home_screen/home_screen.dart';
import 'package:flutter_recipes/services/firestore_service.dart';
import 'package:rxdart/rxdart.dart';

/// `HomeScreenState` is a class that extends `ChangeNotifier` to provide
/// reactive state management for the HomeScreen. It manages the state of
/// recipes, selected recipes, search queries, and loading states.
class GlobalState extends ChangeNotifier {
  final UserProvider userProvider;

  GlobalState(this.userProvider) {
    userProvider.addListener(_updateRecipeStream);
    userProvider.addListener(_updateListStream);
    _updateRecipeStream();
    _updateListStream();
    developer.log('UserProvider initialized with user: ${userProvider.user}',
        name: 'GlobalState');
  }

  /// A `ValueNotifier` of `List<RecipeModel>` objects representing the recipes from StreamBuilder.
  final ValueNotifier<List<RecipeModel>> _recipes =
      ValueNotifier<List<RecipeModel>>([]);
  Stream<List<RecipeModel>>? _recipeStream;

  final ValueNotifier<List<ShoppingListModel>> _lists =
      ValueNotifier<List<ShoppingListModel>>([]);
  Stream<List<ShoppingListModel>>? _listStream; // Added this line

  ValueNotifier<List<ShoppingListModel>> get lists => _lists;

  /// A map of `RecipeModel` objects representing the selected recipes for share, delete, combine shopping list.
  final Map<String, RecipeModel> _selectedRecipes = {};

  /// A map of `ShoppingListModel` objects representing the selected lists.
  final Map<String, ShoppingListModel> _selectedLists = {}; // Added this line

  /// A map of `RecipeModel` objects representing the servings for each selected recipe.
  final Map<String, int> _selectedRecipesServings = {};

  /// A string representing the current search query.
  String _searchQuery = '';

  /// A `BehaviorSubject` of `LoadingState` representing the current loading state.
  final BehaviorSubject<LoadingState> _loadingState =
      BehaviorSubject<LoadingState>.seeded(LoadingState.idle);

  /// An integer representing the minutes required for the recipe.
  int _minutesRequired = 180;

  /// A boolean representing the visibility of the filter.
  bool _isBottomSheetVisible = true;

  /// A boolean representing the state of adding or searching recipes.
  bool _isAddingOrSearchingRecipes = false;

  /// Getter for `_recipes`.
  ValueNotifier<List<RecipeModel>> get recipes => _recipes;

  /// Getter for `_selectedRecipes`.
  Map<String, RecipeModel> get selectedRecipes => _selectedRecipes;

  /// Getter for `_selectedLists`.
  Map<String, ShoppingListModel> get selectedLists =>
      _selectedLists; // Added this line

  /// Getter for `_selectedRecipesServings`.
  Map<String, int> get selectedRecipesServings => _selectedRecipesServings;

  /// Getter for `_searchQuery`.
  String get searchQuery => _searchQuery;

  /// Getter for `_loadingState` stream.
  Stream<LoadingState> get loadingState => _loadingState.stream;

  /// Getter for `_minutesRequired`.
  int get minutesRequired => _minutesRequired;

  /// Getter for `_isBottomSheetVisible`.
  bool get isBottomSheetVisible => _isBottomSheetVisible;

  /// Getter for `_isAddingOrSearchingRecipes`.
  bool get isAddingOrSearchingRecipes => _isAddingOrSearchingRecipes;

  void _updateRecipeStream() {
    if (userProvider.user != null) {
      developer.log('User updated: ${userProvider.user}', name: 'GlobalState');
      _recipeStream =
          FirestoreService().listenToUserRecipes(userProvider.user!.id);
      _streamRecipes();
    } else {
      _recipeStream = null;
    }
  }

  void _updateListStream() {
    if (userProvider.user != null) {
      developer.log('User updated: ${userProvider.user}', name: 'GlobalState');
      _listStream = FirestoreService().listenToUserLists(userProvider.user!.id);
      _streamLists();
    } else {
      _listStream = null;
    }
  }

  void _streamRecipes() {
    _recipeStream?.listen((newRecipes) {
      developer.log("NewRecipes: $newRecipes");
      _recipes.value = newRecipes;
    });
  }

  void _streamLists() {
    _listStream?.listen((newLists) {
      developer.log("NewLists: $newLists");
      _lists.value = newLists;
    });
  }

  /// Setter for `_loadingState`.
  void setLoadingState(LoadingState state) {
    developer.log("Setting _loadingState to $state");
    _loadingState.add(state);
  }

  /// Setter for `_searchQuery`.
  void setSearchQuery(String newQuery) {
    _searchQuery = newQuery;
    notifyListeners();
  }

  /// Setter for `_recipes`.
  void setRecipes(List<RecipeModel> newRecipes) {
    _recipes.value = newRecipes;
  }

  /// Setter for `_minutesRequired`.
  void setMinutesRequired(int newMinutesRequired) {
    _minutesRequired = newMinutesRequired;
    notifyListeners();
  }

  /// Setter for `_isBottomSheetVisible`.
  void toggleBottomSheetVisibility() {
    _isBottomSheetVisible = !_isBottomSheetVisible;
    notifyListeners();
  }

  /// Setter for `_isAddingOrSearchingRecipes`.
  void setAddingOrSearchingRecipes(bool value) {
    _isAddingOrSearchingRecipes = value;
    notifyListeners();
  }

  /// Removes recipes by their IDs from `_recipes`.
  void removeRecipesByIds(List<String> recipeIds) {
    for (var id in recipeIds) {
      _recipes.value.removeWhere((recipe) => recipe.id == id);
    }
    notifyListeners();
  }

  void clearSelectedRecipes() {
    selectedRecipes.clear();
    notifyListeners();
  }

  /// Updates `_selectedRecipes` by adding or removing a recipe.
  void updateSelectedRecipes(String id, bool value, RecipeModel recipe) {
    if (value == true) {
      _selectedRecipes[id] = recipe;
    } else {
      _selectedRecipes.remove(id);
    }
    notifyListeners();
  }

  /// Updates `_selectedLists` by adding or removing a list.
  void updateSelectedLists(String id, bool value, ShoppingListModel list) {
    // Added this method
    if (value == true) {
      _selectedLists[id] = list;
    } else {
      _selectedLists.remove(id);
    }
    notifyListeners();
  }

  /// Updates `_selectedRecipesServings` by adding or removing a recipe.
  void updateSelectedRecipeServings(String recipeId, int servings) {
    _selectedRecipesServings[recipeId] = servings;
    notifyListeners();
  }

  /// Removes a recipe from `_selectedRecipesServings` when it's deselected.
  void removeSelectedRecipeServings(String recipeId) {
    _selectedRecipesServings.remove(recipeId);
    notifyListeners();
  }

  /// Disposes of the resources used by the object.
  @override
  void dispose() {
    _loadingState.close();
    super.dispose();
  }

  Future<void> selectDefaultRecipes() async {
    // Get the two default recipes
    RecipeModel softBoiledEgg = recipes.value[0];
    RecipeModel eggBagel = recipes.value[1];

    // Select the recipes
    updateSelectedRecipes(softBoiledEgg.id, true, softBoiledEgg);
    updateSelectedRecipes(eggBagel.id, true, eggBagel);
  }

}
