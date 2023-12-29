import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/ingredient/ingredient.dart';
import 'package:flutter_recipes/shared/ingredient_icon.dart';

class GridIngredientCard extends StatelessWidget {
  final IngredientWithQuantity ingredient;

  const GridIngredientCard({Key? key, required this.ingredient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              '${ingredient.name}\n${ingredient.quantity.amount} ${ingredient.quantity.units}',
              style: const TextStyle(fontSize: 12),
            ),
            Expanded(
              child: buildIngredientIcon(ingredient.meta.iconPath),
            ),
          ],
        ),
      ),
    );
  }
}
