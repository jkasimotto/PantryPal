import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/ingredient/ingredient.dart';
import 'package:flutter_recipes/shared/grid_ingredient_card.dart';
import 'package:flutter_recipes/shared/compact_ingredient_card.dart';
import 'package:flutter_recipes/screens/recipe_screen/ingredient_dialog.dart';

enum CurrentView { compact, grid, plainText }

class IngredientView extends StatelessWidget {
  final List<IngredientWithQuantity> ingredients;
  final List<TextEditingController> nameControllers;
  final List<TextEditingController> quantityControllers;
  final List<TextEditingController> unitControllers;
  final Function(int) onDelete;
  final Function(int) onSave;
  final CurrentView currentView;

  IngredientView({
    required this.ingredients,
    required this.nameControllers,
    required this.quantityControllers,
    required this.unitControllers,
    required this.onDelete,
    required this.onSave,
    required this.currentView,
  });

  @override
  Widget build(BuildContext context) {
    switch (currentView) {
      case CurrentView.compact:
        return _buildCompactView();
      case CurrentView.grid:
        return _buildGridView();
      case CurrentView.plainText:
        return _buildPlainText();
      default:
        return _buildGridView();
    }
  }

  Widget _buildCompactView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showIngredientDialog(context, index),
          child: CompactIngredientCard(
            ingredient: ingredients[index],
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ingredients.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showIngredientDialog(context, index),
          child: GridIngredientCard(
            ingredient: ingredients[index],
          ),
        );
      },
    );
  }

  Widget _buildPlainText() {
    return TextField(
      readOnly: true,
      maxLines: null,
      controller: TextEditingController(
        text: ingredients
            .map((ingredient) =>
                '${ingredient.quantity.amount} ${ingredient.quantity.units} ${ingredient.name}')
            .join('\n'),
      ),
    );
  }

  void _showIngredientDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return IngredientDialog(
          nameController: nameControllers[index],
          quantityController: quantityControllers[index],
          unitController: unitControllers[index],
          onDelete: onDelete,
          onSave: onSave,
          index: index,
        );
      },
    );
  }
}
