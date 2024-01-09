import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_recipes/models/method/recipe_method_step_model.dart';

class RecipeDocMethodView extends StatefulWidget {
  final List<RecipeMethodStepData> methodData;
  final List<List<TextEditingController>> methodControllers;

  RecipeDocMethodView(
      {required this.methodData, required this.methodControllers});

  @override
  _RecipeDocMethodViewState createState() => _RecipeDocMethodViewState();
}

class _RecipeDocMethodViewState extends State<RecipeDocMethodView> {
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
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                  if (step.duration != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextField(
                        controller: controllers[2],
                        maxLines: null,
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
                        maxLines: null,
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
