// lib/screens/list_screen/list_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/shopping_list/shopping_list_model.dart';
import 'package:flutter_recipes/providers/models/shopping_lists/selected_shopping_list_provider.dart';
import 'package:flutter_recipes/providers/ui/nav_provider.dart';
import 'package:provider/provider.dart';

class ShoppingListCollectionCard extends StatelessWidget {
  final ShoppingList list;

  const ShoppingListCollectionCard({Key? key, required this.list})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the SelectedShoppingListProvider
    final selectedProvider = Provider.of<SelectedShoppingListProvider>(context);

    return Card(
      key: Key(list.id),
      elevation: 5,
      child: ListTile(
        leading: Checkbox(
          value: selectedProvider.selectedLists.containsKey(list.id),
          onChanged: (bool? value) {
            if (value != null) {
              // Update the selected lists using the provider
              selectedProvider.updateSelectedLists(list.id, value, list);
            }
          },
        ),
        title: InkWell(
          onTap: () {
            Provider.of<NavProvider>(context, listen: false)
                .navigateToShoppingListScreen(context, list);
          },
          child: Text(list.recipeTitles.join(', ')),
        ),
      ),
    );
  }
}
