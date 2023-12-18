import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';

class ShoppingList extends StatefulWidget {
  final Future<String> shoppingListFuture;

  const ShoppingList({Key? key, required this.shoppingListFuture})
      : super(key: key);

  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late AnimationController progressController;
  int emojiIndex = 0;
  Timer? emojiTimer;
  List<String> emojis = [
    'assets/emojis/skeleton-chef_s-kiss-pinched-fingers-italian.png',
    'assets/emojis/smiling-cat-wearing-chefs-hat.png',
    'assets/emojis/smiling-dog-wearing-chefs-hat.png'
  ];
  List<String> loadingTexts = [
    'Converting units',
    'Combining quantities',
    'Organising items',
    'Finishing touches'
  ];

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..forward();

    progressController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..forward();

    emojiTimer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      if (mounted) {
        setState(() {
          emojiIndex = (emojiIndex + 1) % emojis.length;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    progressController.dispose();
    emojiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: widget.shoppingListFuture,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return AlertDialog(
          content: snapshot.connectionState == ConnectionState.waiting
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      emojis[emojiIndex],
                      key: ValueKey<String>(emojis[emojiIndex]),
                      width: MediaQuery.of(context).size.width *
                          0.3, // Adjust as needed
                      height: MediaQuery.of(context).size.height *
                          0.3, // Adjust as needed
                    ),
                    const LinearProgressIndicator(),
                    const Gap(8),
                    Text(loadingTexts[emojiIndex]),
                  ],
                )
              : snapshot.hasError
                  ? Text('Error: ${snapshot.error}')
                  : SingleChildScrollView(
                      child: Text(snapshot.data!),
                    ),
          actions: <Widget>[
            if (snapshot.connectionState == ConnectionState.done)
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.copy),
                onPressed: () async {
                  ClipboardData data = ClipboardData(
                    text: (await widget.shoppingListFuture),
                  );
                  Clipboard.setData(data);
                },
              ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
