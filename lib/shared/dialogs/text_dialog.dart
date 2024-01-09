import 'package:flutter/material.dart';

class TextDialogService {
  Future<String> getRecipeTextFromUser(BuildContext context) async {
    final textController = TextEditingController();

    double maxHeight = MediaQuery.of(context).size.height * 0.8;

    return await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text('Enter Recipe'),
                content: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    child: TextField(
                      controller: textController,
                      onChanged: (text) {
                        setState(() {
                        });
                      },
                      decoration: InputDecoration(
                        // hintText: "Ingredients:\nMethod:",
                        hintText:
                            "Boil egg for\n6 minutes to make\na softboiled egg.",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                      minLines: 5,
                      maxLines: null, // Allows the text field to expand
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  textController.text.isEmpty
                      ? Container() // If the text is empty, show an empty Container
                      : TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(textController.text);
                          },
                          child: const Text('OK'),
                        ),
                ],
              );
            });
          },
        ) ??
        '';
  }
}
