import 'package:flutter/material.dart';

class RecipeDocCardServings extends StatelessWidget {
  const RecipeDocCardServings({
    super.key,
    required TextEditingController servingsController,
  }) : _servingsController = servingsController;

  final TextEditingController _servingsController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.group),
        title: TextField(
          controller: _servingsController,
          decoration: const InputDecoration(
            labelText: 'Servings',
          ),
        ),
      ),
    );
  }
}
