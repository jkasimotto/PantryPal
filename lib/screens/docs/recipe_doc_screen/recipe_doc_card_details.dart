import 'package:flutter/material.dart';

class RecipeDocDetailsCard extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController prepTimeController;
  final TextEditingController cookTimeController;
  final TextEditingController cuisineController;
  final TextEditingController courseController;
  final TextEditingController servingsController;

  const RecipeDocDetailsCard({
    Key? key,
    required this.titleController,
    required this.prepTimeController,
    required this.cookTimeController,
    required this.cuisineController,
    required this.courseController,
    required this.servingsController,
  }) : super(key: key);

  @override
  _RecipeDocDetailsCardState createState() => _RecipeDocDetailsCardState();
}

class _RecipeDocDetailsCardState extends State<RecipeDocDetailsCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.details),
        title: Text(widget.titleController.text),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.timer),
            title: TextField(
              controller: widget.prepTimeController,
              decoration: const InputDecoration(
                labelText: 'Prep Time',
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: TextField(
              controller: widget.cookTimeController,
              decoration: const InputDecoration(
                labelText: 'Cook Time',
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: TextField(
              controller: widget.cuisineController,
              decoration: const InputDecoration(
                labelText: 'Cuisine',
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: TextField(
              controller: widget.courseController,
              decoration: const InputDecoration(
                labelText: 'Course',
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: TextField(
              controller: widget.servingsController,
              decoration: const InputDecoration(
                labelText: 'Servings',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
