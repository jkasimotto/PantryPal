import 'package:flutter/material.dart';

class RecipeScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController _titleController;
  final Function _saveRecipe;

  RecipeScreenAppBar(this._titleController, this._saveRecipe);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () => _saveRecipe(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}