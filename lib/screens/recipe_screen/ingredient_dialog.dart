import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_model.dart';
import 'package:flutter_recipes/services/cloud_functions_service.dart'
    as cloud_functions;
import 'package:flutter_recipes/shared/ingredient_icon.dart'; // Import the buildIngredientIcon function

class IngredientDialog extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController unitController;
  final int index;
  final Function(int) onDelete;
  final Function(int, IngredientMeta) onSave;
  final String title;

  const IngredientDialog({
    super.key,
    required this.nameController,
    required this.quantityController,
    required this.unitController,
    required this.onDelete,
    required this.onSave,
    required this.index,
    required this.title,
  });

  @override
  _IngredientDialogState createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<IngredientDialog> {
  final FocusNode nameFocusNode = FocusNode();
  IngredientMeta ingredientMeta = IngredientMeta();

  @override
  void initState() {
    super.initState();
    nameFocusNode.addListener(_onNameFocusChange);
  }

  void _onNameFocusChange() {
    if (!nameFocusNode.hasFocus && widget.nameController.text.length >= 2) {
      cloud_functions
          .getIngredientMetadata(widget.nameController.text)
          .then((meta) {
        if (meta.iconPath.isNotEmpty) {
          setState(() {
            ingredientMeta = meta;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          dialogBackgroundColor: Theme.of(context).colorScheme.surface),
      child: AlertDialog(
        title: Text(widget.title,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              if (ingredientMeta.iconPath.isNotEmpty)
                buildIngredientIcon(ingredientMeta
                    .iconPath), // Display the icon if iconPath is not empty
              TextField(
                controller: widget.nameController,
                focusNode: nameFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextField(
                controller: widget.quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: widget.unitController,
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
              widget.onDelete(widget.index);
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text('Save',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            onPressed: () {
              widget.onSave(widget.index, ingredientMeta);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
