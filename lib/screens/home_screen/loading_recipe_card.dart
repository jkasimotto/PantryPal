import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe_model.dart';
import 'package:flutter_recipes/shared/linear_progress_with_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoadingRecipeCard extends StatefulWidget {
  final RecipeModel recipe;

  const LoadingRecipeCard({Key? key, required this.recipe}) : super(key: key);

  @override
  _LoadingRecipeCardState createState() => _LoadingRecipeCardState();
}

class _LoadingRecipeCardState extends State<LoadingRecipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> positionAnimation;
  int emojiIndex = 0;
  Timer? emojiTimer; // Declare a variable for the timer
  int durationSeconds = 5;
  List<String> emojis = [
    'assets/emojis/skeleton-chef_s-kiss-pinched-fingers-italian.png',
    'assets/emojis/smiling-cat-wearing-chefs-hat.png',
    'assets/emojis/smiling-dog-wearing-chefs-hat.png'
  ];

  @override
  void initState() {
    super.initState();
    switch (widget.recipe.metadata.source) {
      case Source.text:
        durationSeconds = 100;
        break;
      case Source.image:
        durationSeconds = 280;
        break;
      case Source.webpage:
        durationSeconds = 40;
        break;
      case Source.youtube:
        durationSeconds = 90;
        break;
      default:
        durationSeconds = 15;
    }
    controller = AnimationController(
      duration: Duration(seconds: durationSeconds),
      vsync: this,
    )
      ..addListener(() {
        setState(
            () {}); // Trigger a rebuild whenever the animation value changes
      })
      ..forward();

    positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(controller);

    // Assign the timer to the variable
    emojiTimer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          emojiIndex = (emojiIndex + 1) % emojis.length;
        });
      }
    });

  }

  @override
  void dispose() {
    controller.dispose();
    emojiTimer?.cancel(); // Cancel the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (widget.recipe.metadata.source) {
      case Source.text:
        iconData = FontAwesomeIcons.textHeight;
        break;
      case Source.image:
        iconData = FontAwesomeIcons.image;
        break;
      case Source.webpage:
        iconData = FontAwesomeIcons.chrome;
        break;
      case Source.youtube:
        iconData = FontAwesomeIcons.youtube;
        break;
      default:
        iconData = FontAwesomeIcons.circleQuestion;
    }
    return Card(
      key: Key(widget.recipe.id),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(iconData),
            ),
            const SizedBox(width: 16),
            Expanded(
            child: ProgressWithAnimatedWidget(
              customWidget: Transform.translate(
                offset: const Offset(-25, 0),
                child: Image.asset(
                  emojis[emojiIndex],
                  key: ValueKey<String>(emojis[emojiIndex]),
                  width: 50,
                  height: 50,
                ),
              ),
              duration: Duration(seconds: durationSeconds),
            ),
          ),
          ],
        ),
      ),
    );
  }
}