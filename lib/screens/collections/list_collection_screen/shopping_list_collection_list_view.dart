// lib/screens/list_screen/list_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/shopping_list/shopping_list_model.dart';
import 'package:flutter_recipes/models/status.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:flutter_recipes/screens/collections/list_collection_screen/shopping_list_collection_card.dart';
import 'package:flutter_recipes/screens/collections/list_collection_screen/shopping_list_collection_card_loading.dart'; // Import the LoadingListCard
import 'package:provider/provider.dart';

class ShoppingListCollectionListView extends StatelessWidget {
  const ShoppingListCollectionListView({Key? key}) : super(key: key);

  void onChanged(
      BuildContext context, String id, bool? value, ShoppingList list) {
    Provider.of<GlobalState>(context, listen: false)
        .updateSelectedLists(id, value ?? false, list);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ShoppingList>>(
      valueListenable: Provider.of<GlobalState>(context).lists,
      builder: (context, lists, child) {
        String searchQuery = Provider.of<GlobalState>(context).searchQuery;

        List<ShoppingList> filteredLists = lists.where((list) {
          bool matchesSearchQuery = searchQuery.isEmpty ||
              list.recipeTitles.any((title) => title.contains(searchQuery));

          return matchesSearchQuery;
        }).toList();

        return ListView.builder(
          itemCount: filteredLists.length,
          itemBuilder: (context, index) {
            ShoppingList list = filteredLists[index];
            // Check if the list's status is loading
            if (list.meta.status == Status.loading) {
              // If it is, return a LoadingListCard
              return ShoppingListCollectionCardLoading(list: list);
            } else {
              // Otherwise, return a ListCard as before
              return ShoppingListCollectionCard(list: list);
            }
          },
        );
      },
    );
  }
}
