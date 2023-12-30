// lib/screens/list_screen/list_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/shopping_list/shopping_list_model.dart';
import 'package:flutter_recipes/screens/list_collection_screen/list_detail_screen.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:provider/provider.dart';

class ListCard extends StatelessWidget {
  final ShoppingList list;
  final Function onChanged;

  ListCard({Key? key, required this.list, required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key(list.id),
      elevation: 5,
      child: ListTile(
        leading: Checkbox(
          value: Provider.of<GlobalState>(context)
              .selectedLists
              .containsKey(list.id),
          onChanged: (bool? value) {
            onChanged(value);
          },
        ),
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListDetailScreen(shoppingList: list),
              ),
            );
          },
          child: Text(list.recipeTitles.join(', ')),
        ),
      ),
    );
  }
}
