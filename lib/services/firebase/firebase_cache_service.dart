import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FirebaseCacheService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  Future<String> cacheFile(String filePath) async {
    developer.log('cacheFile called with filePath: $filePath',
        name: 'FirebaseCacheService');
    var cachedFile = await _cacheManager.getFileFromCache(filePath);
    if (cachedFile?.file == null) {
      final Reference ref = _storage.ref().child(filePath);
      final Uint8List? fileBytes = await ref.getData(10000000);

      if (fileBytes != null) {
        File file = await _cacheManager.putFile(
          filePath,
          fileBytes,
          fileExtension: "jpg",
        );
        return file.path; // Return the local path of the cached file
      } else {
        developer.log('Failed to download file data for filePath: $filePath',
            name: 'FirebaseCacheService');
        throw Exception('Failed to download file data');
      }
    }
    return cachedFile!.file.path; // Return the local path of the cached file
  }

  Future<String> getFile(String filePath) {
    developer.log('getFile called with filePath: $filePath',
        name: 'FirebaseCacheService');
    return cacheFile(filePath);
  }

  Future<ImageProvider> getImageProvider(String filePath) async {
    developer.log('getImageProvider called with filePath: $filePath',
        name: 'FirebaseCacheService');
    String cachedFilePath = await getFile(filePath);
    return FileImage(File(cachedFilePath));
  }
}
