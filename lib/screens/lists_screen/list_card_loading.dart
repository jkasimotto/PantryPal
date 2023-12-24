import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/shopping_list/shopping_list_model.dart';
import 'package:flutter_recipes/shared/linear_progress_with_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoadingListCard extends StatefulWidget {
  final ShoppingListModel list;

  const LoadingListCard({Key? key, required this.list}) : super(key: key);

  @override
  _LoadingListCardState createState() => _LoadingListCardState();
}

class _LoadingListCardState extends State<LoadingListCard>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> positionAnimation;
  int emojiIndex = 0;
  Timer? emojiTimer; // Declare a variable for the timer
  int durationSeconds = 10;
  List<String> emojis = [
    'assets/emojis/skeleton-chef_s-kiss-pinched-fingers-italian.png',
    'assets/emojis/smiling-cat-wearing-chefs-hat.png',
    'assets/emojis/smiling-dog-wearing-chefs-hat.png'
  ];

  @override
  void initState() {
    super.initState();
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
    emojiTimer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
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
    return Card(
      key: Key(widget.list.id),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(FontAwesomeIcons.list),
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