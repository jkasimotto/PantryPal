import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future<List<String>> imagesToBase64(List<XFile> mediaList) async {
  List<String> base64Images = [];
  for (var media in mediaList) {
    File imageFile = File(media.path);
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    base64Images.add(base64Image);
  }
  return base64Images;
}
