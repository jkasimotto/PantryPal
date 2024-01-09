import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_model.dart';
import 'package:flutter_recipes/shared/ingredients/ingredient_icon.dart';

class ViewIngredientGridCard extends StatelessWidget {
  final IngredientWithQuantity ingredient;

  const ViewIngredientGridCard({Key? key, required this.ingredient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              '${ingredient.name}\n${ingredient.quantity.prettyQuantity}',
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
