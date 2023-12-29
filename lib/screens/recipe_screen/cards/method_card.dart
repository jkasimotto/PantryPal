import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/method/recipe_method_step_model.dart';
import 'package:flutter_recipes/screens/recipe_screen/method_view.dart';

class RecipeDocMethodListCard extends StatelessWidget {
  const RecipeDocMethodListCard({
    super.key,
    required List<RecipeMethodStepData> methodSteps,
    required List<List<TextEditingController>> methodControllers,
  })  : _methodSteps = methodSteps,
        _methodControllers = methodControllers;

  final List<RecipeMethodStepData> _methodSteps;
  final List<List<TextEditingController>> _methodControllers;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.list),
        title: const Text('Method'),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MethodView(
                methodData: _methodSteps,
                methodControllers: _methodControllers),
          ),
        ],
      ),
    );
  }
}
