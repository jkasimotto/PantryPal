import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/shopping_list/shopping_list_model.dart';
import 'package:flutter_recipes/providers/models/user/user_provider.dart';
import 'package:flutter_recipes/services/firebase/firestore_service.dart';
import 'dart:developer' as developer;
import 'package:uuid/uuid.dart';

class ShoppingListProvider extends ChangeNotifier {
  final UserProvider userProvider;
  final FirestoreService firestoreService = FirestoreService();
  final ValueNotifier<List<ShoppingList>> _lists =
      ValueNotifier<List<ShoppingList>>([]);
  final ValueNotifier<ShoppingList> listNotifier =
      ValueNotifier<ShoppingList>(ShoppingList.empty()); // Added this line
  Stream<List<ShoppingList>>? _listStream;
  final uuid = const Uuid();

  ShoppingListProvider({
    required this.userProvider,
  }) {
    userProvider.addListener(_updateListStream);
    _updateListStream();
  }

  ValueNotifier<List<ShoppingList>> get lists => _lists;

  void _updateListStream() {
    if (userProvider.user != null) {
      developer.log('User updated: ${userProvider.user}',
          name: 'ShoppingListProvider');
      _listStream = firestoreService.listenToUserLists(userProvider.user!.id);
      _streamLists();
    } else {
      _listStream = null;
    }
  }

  void _streamLists() {
    _listStream?.listen((newLists) {
      developer.log("NewLists: $newLists");
      _lists.value = newLists;

      developer.log("ListNotifier: ${listNotifier.value}");

      // Check if the current list in listNotifier is in the updated lists
      if (newLists.any((list) => list.id == listNotifier.value.id)) {
        var updatedList = newLists.firstWhere(
          (list) => list.id == listNotifier.value.id,
        );

        developer.log("ListNotifier: ${listNotifier.value}");
        // If it is, update listNotifier
        listNotifier.value = updatedList;
      }
    });
  }

  void setLists(List<ShoppingList> newLists) {
    _lists.value = newLists;
  }

  void setShoppingList(ShoppingList newList) {
    // Added this line
    listNotifier.value = newList; // Added this line
  } // Added this line

  void removeListsByIds(List<String> listIds) {
    for (var id in listIds) {
      _lists.value.removeWhere((list) => list.id == id);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    userProvider.removeListener(_updateListStream);
    super.dispose();
  }
}
