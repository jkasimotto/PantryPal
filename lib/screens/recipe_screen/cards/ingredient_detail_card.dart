import 'package:flutter/material.dart';

// Base class for ingredient cards
abstract class BaseIngredientCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  static const double defaultBorderWidth = 2.0; // Shared constant border width

  const BaseIngredientCard({
    Key? key,
    required this.child,
    required this.borderColor,
    double borderWidth = defaultBorderWidth, // Use the shared constant
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(
            color: borderColor,
            width: defaultBorderWidth), // Use the shared constant
      ),
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: child,
    );
  }
}

// IngredientCard for displaying an ingredient
class IngredientCard extends BaseIngredientCard {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController unitController;

  IngredientCard({
    Key? key,
    required this.nameController,
    required this.quantityController,
    required this.unitController,
    required Color borderColor,
  }) : super(
          key: key,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${nameController.text}\n${_formatQuantity(quantityController.text)} ${unitController.text}',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          borderColor: borderColor,
        );

  // Helper method to format the quantity
  static String _formatQuantity(String quantity) {
    double? value = double.tryParse(quantity);
    if (value != null && value == value.toInt().toDouble()) {
      return value.toInt().toString(); // Convert to integer string if ends with .0
    }
    return quantity; // Return the original string if it's not a float ending with .0
  }
}

// AddIngredientCard for adding a new ingredient
class AddIngredientCard extends BaseIngredientCard {
  AddIngredientCard({
    Key? key,
    required Widget child,
    required Color borderColor,
  }) : super(
          key: key,
          child: child,
          borderColor: borderColor,
        );
}
