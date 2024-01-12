// lib/screens/home_screen/dialogs/cookbook_input_dialog.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_recipes/services/user_input_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CookbookInputDialog extends StatefulWidget {
  final UserInputService userInputService;

  const CookbookInputDialog({super.key, required this.userInputService});

  @override
  // ignore: library_private_types_in_public_api
  _CookbookInputDialogState createState() => _CookbookInputDialogState();
}

class _CookbookInputDialogState extends State<CookbookInputDialog> {
  XFile? titleImage;
  List<XFile?> ingredientImages = [null, null];
  List<XFile?> methodImages = [null, null, null];

  void onImageDeleted(int index, String label) {
    setState(() {
      switch (label) {
        case 'Title':
          titleImage = null;
          break;
        case 'Ingredients':
          ingredientImages[index] = null;
          break;
        case 'Method':
          methodImages[index] = null;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<XFile?> allImages = [titleImage] + ingredientImages + methodImages;
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset('assets/emojis/smiling-dog-wearing-chefs-hat.png'),
            const Text(
              'Photograph the title, ingredients, and method.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ...List.generate(
                  4,
                  (index) => Expanded(
                    child: _buildThumbnail(allImages, index),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Send'),
                  onPressed: () {
                    if (allImages.where((image) => image != null).length > 0) {
                      Navigator.of(context).pop({
                        'titleImage': [titleImage],
                        'ingredientImages': ingredientImages,
                        'methodImages': methodImages,
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(List<XFile?> allImages, int index) {
    if (index < allImages.length && allImages[index] != null) {
      return Image.file(
        File(allImages[index]!.path),
        fit: BoxFit.cover,
      );
    } else {
      return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.camera),
                      title: Text('Take a photo'),
                      onTap: () async {
                        final selectedImage = await widget.userInputService
                            .selectImageFromCamera(false);
                        if (selectedImage != null) {
                          setState(() {
                            if (titleImage == null) {
                              titleImage = selectedImage;
                            } else if (ingredientImages.contains(null)) {
                              ingredientImages[ingredientImages.indexWhere(
                                  (image) => image == null)] = selectedImage;
                            } else if (methodImages.contains(null)) {
                              methodImages[methodImages.indexWhere(
                                  (image) => image == null)] = selectedImage;
                            }
                          });
                        }
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Select from gallery'),
                      onTap: () async {
                        final selectedImages = await widget.userInputService
                            .selectImagesFromGallery(false);
                        if (selectedImages != null &&
                            selectedImages.isNotEmpty) {
                          setState(() {
                            for (var selectedImage in selectedImages) {
                              if (titleImage == null) {
                                titleImage = selectedImage;
                              } else if (ingredientImages.contains(null)) {
                                ingredientImages[ingredientImages.indexWhere(
                                    (image) => image == null)] = selectedImage;
                              } else if (methodImages.contains(null)) {
                                methodImages[methodImages.indexWhere(
                                    (image) => image == null)] = selectedImage;
                              }
                            }
                          });
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: Icon(Icons.add_a_photo),
        ),
      );
    }
  }
}
