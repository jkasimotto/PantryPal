import 'package:flutter/foundation.dart';
import 'package:flutter_recipes/models/user/user_model.dart';
import 'package:flutter_recipes/services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  FirestoreService firestoreService = FirestoreService();
  UserModel? _user;

  UserModel? get user => _user;

  set firebaseUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }
}