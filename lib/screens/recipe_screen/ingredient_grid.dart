import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/ingredient_model.dart';
import 'package:flutter_recipes/screens/recipe_screen/cards/ingredient_detail_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/ingredient_dialog.dart';

class IngredientGrid extends StatelessWidget {
  final List<IngredientData> ingredients;
  final List<TextEditingController> nameControllers;
  final List<TextEditingController> quantityControllers;
  final List<TextEditingController> unitControllers;
  final Function(int) onDelete;
  final Function(int) onSave;

  IngredientGrid({
    required this.ingredients,
    required this.nameControllers,
    required this.quantityControllers,
    required this.unitControllers,
    required this.onDelete,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ingredients.length + 1, // Add 1 for the new card
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // adjust the number of cards in a row
        ),
        itemBuilder: (BuildContext context, int index) {
          // If it's the last index, return the add new ingredient card
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return IngredientDialog(
                    nameController: nameControllers[index],
                    quantityController: quantityControllers[index],
                    unitController: unitControllers[index],
                    index: index,
                    onDelete: onDelete,
                    onSave: onSave,
                  );
                },
              );
            },
            child: (index == ingredients.length)
                ? AddIngredientCard(
                    child: const Icon(Icons.add), // Add icon
                    borderColor: Theme.of(context).colorScheme.secondary,
                  )
                : IngredientCard(
                    nameController: nameControllers[index],
                    quantityController: quantityControllers[index],
                    unitController: unitControllers[index],
                    borderColor: Theme.of(context).colorScheme.secondary,
                  ),
          );
        });
  }
}
