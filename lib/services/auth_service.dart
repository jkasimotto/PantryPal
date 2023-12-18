import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_recipes/models/user_model.dart' as models;
import 'package:flutter_recipes/providers/user_provider.dart';
import 'package:flutter_recipes/services/firestore_service.dart';
import 'package:flutter_recipes/services/logger.dart';
import 'package:flutter_recipes/services/recipe_extraction_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut(BuildContext context) async {
    await _firebaseAuth.signOut();
    if (context.mounted) {
      _setFirebaseUserInProvider(null, context);
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<String> signIn(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = _firebaseAuth.currentUser;
      models.UserModel? userModel = await _updateOrCreateUser(user, context);
      _setFirebaseUserInProvider(userModel, context);
      return "Signed in";
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An unknown error occurred';
    }
  }

  Future<String> signUp(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = _firebaseAuth.currentUser;
      models.UserModel? userModel = await _updateOrCreateUser(user, context);
      _setFirebaseUserInProvider(userModel, context);
      return "Signed up";
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An unknown error occurred';
    }
  }

  Future<String> signInWithGoogle({required BuildContext context}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        Logger().log("User uid ${user.uid}");
      }
      if (context.mounted) {
        models.UserModel? userModel = await _updateOrCreateUser(user, context);
        _setFirebaseUserInProvider(userModel, context);
      }
      return "Signed in with Google";
    } catch (e) {
      return 'An unknown error occurred';
    }
  }

  Future<models.UserModel?> _updateOrCreateUser(
      User? user, BuildContext context) async {
    if (user != null) {
      bool userExists =
          await _firestoreService.documentExists(user.uid, 'users');
      if (!userExists) {
        models.UserData newUser = models.UserData(
            name: user.displayName ?? 'Default Name',
            email: user.email ?? 'default@email.com',
            subscriptionPlan: 'free');
        models.UserMetadata newMetadata = models.UserMetadata(
            id: user.uid,
            signInCount: 0,
            recipeGenerationCount: {
              'text': 0,
              'youtube': 0,
              'webpage': 0,
              'camera': 0,
            },
            hasCompletedHomeScreenTutorial: false,
            hasCompletedTextAction: false,
            hasCompletedYoutubeAction: false,
            hasCompletedCameraAction: false,
            hasCompletedWebAction: false);
        models.UserModel newUserModel = models.UserModel(data: newUser, metadata: newMetadata);
        await _firestoreService.createDocument(newUserModel, 'users');
        await RecipeExtractionService().createInitialRecipes(user.uid, _firestoreService);
        return newUserModel;
      } else {
        models.UserModel existingUser = await _firestoreService.readDocument(
            user.uid, 'users', (data) => models.UserModel.fromJson(data));
        models.UserData updatedUser = models.UserData(
            name: user.displayName ?? existingUser.data.name,
            email: user.email ?? existingUser.data.email,
            subscriptionPlan: existingUser.data.subscriptionPlan);
        models.UserMetadata updatedMetadata = models.UserMetadata(
            id: user.uid,
            signInCount: existingUser.metadata.signInCount + 1,
            lastActive: DateTime.now(),
            recipeGenerationCount: existingUser.metadata.recipeGenerationCount,
            hasCompletedHomeScreenTutorial: existingUser.metadata.hasCompletedHomeScreenTutorial,
            hasCompletedTextAction: existingUser.metadata.hasCompletedTextAction,
            hasCompletedYoutubeAction: existingUser.metadata.hasCompletedYoutubeAction,
            hasCompletedCameraAction: existingUser.metadata.hasCompletedCameraAction,
            hasCompletedWebAction: existingUser.metadata.hasCompletedWebAction);
        models.UserModel updatedUserModel = models.UserModel(data: updatedUser, metadata: updatedMetadata);
        await _firestoreService.updateDocument(updatedUserModel, 'users');
        return updatedUserModel;
      }
    }
    return null;
  }

  void _setFirebaseUserInProvider(models.UserModel? user, BuildContext context) {
    Provider.of<UserProvider>(context, listen: false).firebaseUser = user;
  }

  Future<void> deleteAccount(BuildContext context) async {
  User? user = _firebaseAuth.currentUser;
  if (user != null) {
    // Delete user data from Firestore
    await _firestoreService.deleteDocument(user.uid, 'users');
    // Delete user from Firebase Authentication
    await user.delete();
    // Sign out the user
    await signOut(context);
  }
}

}
