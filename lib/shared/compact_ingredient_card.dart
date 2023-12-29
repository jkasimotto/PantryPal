import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/ingredient/ingredient.dart';
import 'package:flutter_recipes/shared/ingredient_icon.dart';

class CompactIngredientCard extends StatelessWidget {
  final IngredientWithQuantity ingredient;

  const CompactIngredientCard({
    Key? key,
    required this.ingredient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: buildIngredientIcon(ingredient.meta.iconPath),
        title: Text(ingredient.name),
        subtitle:
            Text('${ingredient.quantity.amount} ${ingredient.quantity.units}'),
      ),
    );
  }
}
