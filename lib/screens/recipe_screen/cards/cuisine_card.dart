import 'package:flutter/material.dart';

class RecipeDocCuisineCard extends StatelessWidget {
  const RecipeDocCuisineCard({
    super.key,
    required TextEditingController cuisineController,
    required TextEditingController courseController,
  })  : _cuisineController = cuisineController,
        _courseController = courseController;

  final TextEditingController _cuisineController;
  final TextEditingController _courseController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListTile(
              leading: const Icon(Icons.restaurant),
              title: TextField(
                controller: _cuisineController,
                decoration: const InputDecoration(
                  labelText: 'Cuisine',
                ),
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: TextField(
                controller: _courseController,
                decoration: const InputDecoration(
                  labelText: 'Course',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
