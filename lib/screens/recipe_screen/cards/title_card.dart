import 'package:flutter/material.dart';

class RecipeDocTitleCard extends StatelessWidget {
  final TextEditingController titleController;

  const RecipeDocTitleCard({Key? key, required this.titleController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
