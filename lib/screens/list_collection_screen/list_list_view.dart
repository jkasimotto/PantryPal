// lib/screens/list_screen/list_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/shopping_list/shopping_list.dart';
import 'package:flutter_recipes/models/status.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:flutter_recipes/screens/list_collection_screen/list_card.dart';
import 'package:flutter_recipes/screens/list_collection_screen/list_card_loading.dart'; // Import the LoadingListCard
import 'package:provider/provider.dart';

class ListListView extends StatelessWidget {
  const ListListView({Key? key}) : super(key: key);

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
              return LoadingListCard(list: list);
            } else {
              // Otherwise, return a ListCard as before
              return ListCard(
                list: list,
                onChanged: (value) => onChanged(context, list.id, value, list),
              );
            }
          },
        );
      },
    );
  }
}
