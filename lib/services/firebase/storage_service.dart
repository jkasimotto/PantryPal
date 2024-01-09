import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile, String path) async {
    UploadTask uploadTask = _storage.ref(path).putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future<String> getImageUrl(String path) async {
    String imageUrl = await _storage.ref(path).getDownloadURL();
    return imageUrl;
  }
}