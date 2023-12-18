import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe_method_step_model.dart';
import 'package:flip_card/flip_card.dart';

class MethodView extends StatefulWidget {
  final List<RecipeMethodStepData> methodData;
  final List<List<TextEditingController>> methodControllers;

  MethodView({required this.methodData, required this.methodControllers});

  @override
  _MethodViewState createState() => _MethodViewState();
}

class _MethodViewState extends State<MethodView> {
  late FlipCardController flipCardController;

  @override
  void initState() {
    super.initState();
    flipCardController = FlipCardController();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.methodData.length,
      itemBuilder: (context, index) {
        final step = widget.methodData[index];
        final controllers = widget.methodControllers[index];
        return FlipCard(
          controller: flipCardController,
          direction: FlipDirection.HORIZONTAL, // default
          front: Card(
            child: ListTile(
              title: Text('Step ${step.stepNumber}'),
              subtitle: Text(step.description),
            ),
          ),
          back: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: controllers[1],
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                  if (step.duration != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextField(
                        controller: controllers[2],
                        decoration: const InputDecoration(
                          labelText: 'Duration',
                        ),
                      ),
                    ),
                  if (step.additionalNotes != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextField(
                        controller: controllers[3],
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      // Save the edits here
                      flipCardController.toggleCard();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}