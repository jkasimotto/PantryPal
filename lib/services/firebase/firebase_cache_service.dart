import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FirebaseCacheService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  Future<String> cacheFile(String filePath) async {
    var cachedFile = await _cacheManager.getFileFromCache(filePath);
    if (cachedFile?.file == null) {
      final Reference ref = _storage.ref().child(filePath);
      final Uint8List? fileBytes = await ref.getData(10000000);

      if (fileBytes != null) {
        await _cacheManager.putFile(
          filePath,
          fileBytes,
          fileExtension: "jpg",
        );
      } else {
        throw Exception('Failed to download file data');
      }
    }
    return filePath;
  }

  Future<String> getFile(String filePath) {
    return cacheFile(filePath);
  }
}
