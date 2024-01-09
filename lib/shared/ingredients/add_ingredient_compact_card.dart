// lib/shared/compact_add_ingredient_card.dart
import 'package:flutter/material.dart';

class AddIngredientCompactCard extends StatelessWidget {
  const AddIngredientCompactCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.add),
        title: Text('Add Ingredient'),
      ),
    );
  }
}
