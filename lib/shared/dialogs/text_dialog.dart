import 'dart:math';

import 'package:flutter/material.dart';

class TextDialogService {
  Future<String> getRecipeTextFromUser(BuildContext context) async {
    final textController = TextEditingController();

    double maxHeight = MediaQuery.of(context).size.height * 0.8;

    Color surfaceColor = Theme.of(context).colorScheme.surface;
    Color onBackgroundColor = Theme.of(context).colorScheme.onBackground;
    Color primaryColor = Theme.of(context).colorScheme.primary;

    List<String> hintTexts = [
      'Boil egg for 6 minutes to make a softboiled egg',
    ];

    String hintText = hintTexts[Random().nextInt(hintTexts.length)];

    return await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  height: maxHeight,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: textController,
                          onChanged: (text) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintMaxLines: 20,
                            hintText: hintText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: surfaceColor,
                          ),
                          minLines: 5,
                          maxLines: null, // Allows the text field to expand
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          TextButton(
                            child: Text('Cancel',
                                style: TextStyle(color: onBackgroundColor)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            onPressed: textController.text.isEmpty
                                ? null // If the text is empty, disable the button
                                : () {
                                    Navigator.of(context)
                                        .pop(textController.text);
                                  },
                            child: Text('OK',
                                style: TextStyle(color: onBackgroundColor)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        ) ??
        '';
  }
}
