// lib/screens/list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_recipes/providers/models/shopping_lists/selected_shopping_list_provider.dart';
import 'package:flutter_recipes/services/firebase/firestore_service.dart';
import 'package:provider/provider.dart';

class ShoppingListCollectionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final FirestoreService firestoreService = FirestoreService();

  ShoppingListCollectionAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedProvider = Provider.of<SelectedShoppingListProvider>(context);
    final selectedLists = selectedProvider.selectedLists;

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      actions: selectedLists.isNotEmpty
          ? <Widget>[
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  var ids = selectedLists.keys.toList();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text(
                            'Are you sure you want to delete these items?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Delete'),
                            onPressed: () async {
                              await firestoreService.deleteDocuments(
                                  ids, 'lists');
                              selectedProvider.clearSelectedLists();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
