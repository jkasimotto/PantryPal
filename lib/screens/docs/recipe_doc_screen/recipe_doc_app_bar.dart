import 'package:flutter/material.dart';

class RecipeDocAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function _saveRecipe;

  RecipeDocAppBar(this._saveRecipe);

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
