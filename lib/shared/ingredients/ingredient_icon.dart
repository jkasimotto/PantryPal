import 'dart:developer' as developer;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

Future<String> cacheImage(String iconPath) async {
  final FirebaseStorage storage = FirebaseStorage.instance;

  final defaultCacheManager = DefaultCacheManager();

  // Check if the image file is in the cache
  var cachedFile = await defaultCacheManager.getFileFromCache(iconPath);
  if (cachedFile?.file == null) {
    developer.log('Image not found in cache, downloading...',
        name: 'cacheImage');

    // Download your image data
    final Reference ref = storage.ref().child(iconPath);
    final Uint8List? imageBytes = await ref.getData(10000000);

    if (imageBytes != null) {
      // developer.log('Image downloaded, size: ${imageBytes.length} bytes',
      //     name: 'cacheImage');

      // Put the image file in the cache
      await defaultCacheManager.putFile(
        iconPath,
        imageBytes,
        fileExtension: "jpg",
      );
      // developer.log('Image cached successfully', name: 'cacheImage');
    } else {
      // Handle the case where imageBytes is null
      // developer.log('Failed to download image data', name: 'cacheImage');
      throw Exception('Failed to download image data');
    }
  } else {
    // developer.log('Image found in cache', name: 'cacheImage');
  }

  // Return image download URL
  return iconPath;
}

Widget buildIngredientIcon(String iconPath) {
  String defaultIconPath = 'assets/images/icons/food/default.png';
  if (iconPath.isEmpty) {
    iconPath = defaultIconPath;
  }

  return FutureBuilder(
    future: cacheImage(iconPath),
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        // Return the default image when an error occurs
        return Image.asset(defaultIconPath);
      } else {
        return CachedNetworkImage(
          imageUrl: snapshot.data!,
          fit: BoxFit.cover,
          cacheKey: iconPath,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => Image.asset(defaultIconPath),
        );
      }
    },
  );
}
