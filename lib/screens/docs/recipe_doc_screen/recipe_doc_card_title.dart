import 'package:flutter/material.dart';

class RecipeDocCardTitle extends StatelessWidget {
  final TextEditingController titleController;

  const RecipeDocCardTitle({Key? key, required this.titleController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
