import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_model.dart';
import 'package:flutter_recipes/shared/ingredients/ingredient_icon.dart';

class ViewIngredientCompactCard extends StatelessWidget {
  final IngredientWithQuantity ingredient;

  const ViewIngredientCompactCard({
    Key? key,
    required this.ingredient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: buildFirebaseNetworkImage(
            firebaseImagePath: ingredient.meta.iconPath),
        title: Text(ingredient.name),
        subtitle: Text('${ingredient.quantity.prettyQuantity}'),
      ),
    );
  }
}
