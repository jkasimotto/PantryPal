import 'package:flutter/material.dart';

class RecipeDocTimerCard extends StatelessWidget {
  const RecipeDocTimerCard({
    super.key,
    required TextEditingController prepTimeController,
    required TextEditingController cookTimeController,
  })  : _prepTimeController = prepTimeController,
        _cookTimeController = cookTimeController;

  final TextEditingController _prepTimeController;
  final TextEditingController _cookTimeController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListTile(
              leading: const Icon(Icons.timer),
              title: TextField(
                controller: _prepTimeController,
                decoration: const InputDecoration(
                  labelText: 'Prep Time',
                ),
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              leading: const Icon(Icons.timer),
              title: TextField(
                controller: _cookTimeController,
                decoration: const InputDecoration(
                  labelText: 'Cook Time',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
