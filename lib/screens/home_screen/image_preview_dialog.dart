// lib/screens/home_screen/image_preview_dialog.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePreviewDialog extends StatelessWidget {
  final List<XFile> images;

  const ImagePreviewDialog({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Preview Images'),
      content: SingleChildScrollView(
        child: Column(
          children: images.map((image) {
            return Dismissible(
              key: Key(image.path),
              onDismissed: (direction) {
                images.remove(image);
              },
              child: Image.file(File(image.path)),
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            images.clear(); // Clear the images list
            Navigator.of(context).pop(false); // Pop the dialog
          },
        ),
        TextButton(
          child: const Text('Add More'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        TextButton(
          child: const Text('Done'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
  }
}
