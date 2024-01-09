// lib/shared/grid_add_ingredient_card.dart
import 'package:flutter/material.dart';

class AddIngredientGridCard extends StatelessWidget {
  const AddIngredientGridCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Center(
        child: Icon(Icons.add),
      ),
    );
  }
}
