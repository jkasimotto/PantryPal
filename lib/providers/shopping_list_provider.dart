import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/shopping_list/shopping_list_model.dart';
import 'package:flutter_recipes/providers/selected_recipes_provider.dart';
import 'package:flutter_recipes/providers/user_provider.dart';
import 'package:flutter_recipes/services/ad_service.dart';
import 'package:flutter_recipes/services/firestore_service.dart';
import 'dart:developer' as developer;
import 'package:uuid/uuid.dart';

class ShoppingListProvider extends ChangeNotifier {
  final UserProvider userProvider;
  final FirestoreService firestoreService = FirestoreService();
  final ValueNotifier<List<ShoppingList>> _lists =
      ValueNotifier<List<ShoppingList>>([]);
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
    });
  }

  @override
  void dispose() {
    userProvider.removeListener(_updateListStream);
    super.dispose();
  }
}
