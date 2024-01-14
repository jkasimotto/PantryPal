// lib/services/user_input_service.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_recipes/shared/dialogs/text_dialog.dart';
import 'package:flutter_recipes/shared/dialogs/youtube_select_dialog.dart';
import 'package:flutter_recipes/shared/image/image_preview_dialog.dart';
import 'package:image_picker/image_picker.dart';

class UserInputService {
  final ImagePicker picker = ImagePicker();

  Future<XFile?> selectImageFromCamera(bool hasCompletedCameraAction) async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      imageQuality: 85,
    );
    return image;
  }

  Future<List<XFile>?> selectImagesFromCamera(
      BuildContext context, bool hasCompletedCameraAction) async {
    List<XFile> images = [];
    bool addMore = true;

    while (addMore) {
      final XFile? image =
          await selectImageFromCamera(hasCompletedCameraAction);
      if (image != null) {
        images.add(image);
        addMore = await showDialog<bool>(
              context: context,
              builder: (context) => ImagePreviewDialog(images: images),
            ) ??
            false;
      } else {
        addMore = false;
      }
    }

    return images;
  }

  Future<List<XFile>?> selectImagesFromGallery(
      bool hasCompletedGalleryAction) async {
    if (!hasCompletedGalleryAction) {
      // Display showcase here
    }
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 800,
      imageQuality: 85,
    );
    return images;
  }

  Future<List<XFile>?> showImageSourceSelection(BuildContext context) async {
    return showModalBottomSheet<List<XFile>>(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('From Camera'),
                    onTap: () async {
                      List<XFile>? images =
                          await selectImagesFromCamera(context, true);
                      Navigator.of(context).pop(images);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('From Gallery'),
                    onTap: () async {
                      List<XFile>? images = await selectImagesFromGallery(true);
                      Navigator.of(context).pop(images);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<String?> selectYoutubeUrl(
      BuildContext context, bool hasCompletedYoutubeAction) async {
    if (!hasCompletedYoutubeAction) {
      // Display showcase here
    }
    final completer = Completer<String>();
    showDialog(
      context: context,
      builder: (context) => YoutubeSelectDialog(
        onUrlSelected: (url) {
          completer.complete(url);
        },
      ),
    );
    return await completer.future;
  }

  Future<String?> selectRecipeText(
      BuildContext context, bool hasCompletedTextAction) async {
    String recipeText =
        await TextDialogService().getRecipeTextFromUser(context);
    if (recipeText == '') return null;
    return recipeText;
  }

  Future<String?> selectUrl(
      BuildContext context, bool hasCompletedWebAction) async {
    final urlController = TextEditingController();
    String? url = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SimpleDialog(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surface, // Use surface color from theme
              title: const Text('Enter URL'),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      hintText: "https://",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface), // Use onSurface color from theme for border
                      ),
                    ),
                    onChanged: (text) {
                      setState(() {}); // This will cause the dialog to rebuild
                    },
                  ),
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  onPressed: urlController.text.isEmpty
                      ? null
                      : () {
                          Navigator.of(context).pop(urlController.text);
                        },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
    if (url == '' || url == null) return null;
    return url;
  }
}
