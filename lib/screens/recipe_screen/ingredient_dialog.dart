import 'package:flutter/material.dart';

class IngredientDialog extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController unitController;
  final int index;
  final Function(int) onDelete;
  final Function(int) onSave;

  const IngredientDialog({super.key, 
    required this.nameController,
    required this.quantityController,
    required this.unitController,
    required this.onDelete,
    required this.onSave,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          dialogBackgroundColor: Theme.of(context).colorScheme.surface),
      child: AlertDialog(
        title: Text('Edit Ingredient',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Delete',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            onPressed: () {
              if (index != null) {
                onDelete(index!);
              }
            },
          ),
          TextButton(
            child: Text('Save',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            onPressed: () {
              onSave(index);
            },
          ),
        ],
      ),
    );
  }
}
