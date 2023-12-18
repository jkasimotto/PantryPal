// lib/screens/home_screen/dialogs/cookbook_input_dialog.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_recipes/services/user_input_service.dart';
import 'package:flutter_recipes/shared/bottom_nav.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CookbookInputDialog extends StatefulWidget {
  final UserInputService userInputService;

  CookbookInputDialog({required this.userInputService});

  @override
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
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: viewportConstraints.maxHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildRow(
                      'Title',
                      viewportConstraints.maxHeight / 3,
                      [titleImage],
                      (index, image) => setState(() => titleImage = image),
                      (index) => onImageDeleted(index, 'Title')),
                ),
                const Divider(),
                Expanded(
                  child: _buildRow(
                      'Ingredients',
                      viewportConstraints.maxHeight / 3,
                      ingredientImages,
                      (index, image) =>
                          setState(() => ingredientImages[index] = image),
                      (index) => onImageDeleted(index, 'Ingredients')),
                ),
                const Divider(),
                Expanded(
                  child: _buildRow(
                      'Method',
                      viewportConstraints.maxHeight / 3,
                      methodImages,
                      (index, image) =>
                          setState(() => methodImages[index] = image),
                      (index) => onImageDeleted(index, 'Method')),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.x),
            label: 'Cancel',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.check),
            label: 'Create',
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        unselectedItemColor: Theme.of(context).colorScheme.onPrimary,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            // Create a map of images
            Map<String, List<XFile?>> imagesMap = {
              'titleImage': [titleImage],
              'ingredientImages': ingredientImages,
              'methodImages': methodImages,
            };

            // Pop the map
            Navigator.pop(context, imagesMap);
          }
        },
      ),
    );
  }

Widget _buildRow(String label, double height, List<XFile?> images,
      Function(int, XFile) onImageSelected, Function(int) onImageDeleted) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 20.0,
              ),
            ),
            const Divider(),
            Expanded(
              child: SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length + 1,
                  itemBuilder: (context, index) {
                    if (index == images.length) {
                      if (images.where((image) => image != null).length ==
                          images.length) {
                        return Container();
                      }
                      return Align(
                        alignment: Alignment.center,
                        child: NewImageButton(
                          userInputService: widget.userInputService,
                          onImageSelected: onImageSelected,
                          images: images,
                        ),
                      );
                    } else {
                      XFile? image = images[index];
                      if (image != null) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.file(
                                File(image.path),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: Transform.translate(
                                offset: const Offset(10, -10),
                                child: Transform.scale(
                                  scale: 0.5,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: FaIcon(FontAwesomeIcons.x,
                                          size: 30.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                      onPressed: () => onImageDeleted(index),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewImageButton extends StatelessWidget {
  final UserInputService userInputService;
  final Function(int, XFile) onImageSelected;
  final List<XFile?> images;

  const NewImageButton({
    Key? key,
    required this.userInputService,
    required this.onImageSelected,
    required this.images,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.7,
      alignment: Alignment.centerLeft,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.camera,
                size: 30.0,
              ),
              onPressed: () async {
                final selectedImage =
                    await userInputService.selectImageFromCamera(false);
                if (selectedImage != null) {
                  int index = images.indexWhere((image) => image == null);
                  if (index != -1) {
                    onImageSelected(index, selectedImage);
                  }
                }
              },
            ),
            const VerticalDivider(),
            IconButton(
              icon: const Icon(Icons.photo_library, size: 30.0),
              onPressed: () async {
                final selectedImages =
                    await userInputService.selectImagesFromGallery(false);
                if (selectedImages != null) {
                  for (var i = 0; i < selectedImages.length; i++) {
                    int index = images.indexWhere((image) => image == null);
                    if (index != -1) {
                      onImageSelected(index, selectedImages[i]);
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
