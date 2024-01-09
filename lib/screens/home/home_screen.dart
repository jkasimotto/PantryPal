// lib/screens/home_screen.dart
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/user/user_model.dart';
import 'package:flutter_recipes/providers/models/user/user_provider.dart';
import 'package:flutter_recipes/providers/ui/nav_provider.dart'; // Added this import
import 'package:flutter_recipes/screens/collections/recipe_collection_screen/recipe_collection_app_bar.dart';
import 'package:flutter_recipes/screens/collections/recipe_collection_screen/recipe_collection_bottom_sheet_filter.dart';
import 'package:flutter_recipes/screens/collections/recipe_collection_screen/recipe_collection_bottom_sheet_add_recipe.dart';
import 'package:flutter_recipes/screens/collections/list_collection_screen/shopping_list_collection_screen.dart';
import 'package:flutter_recipes/screens/collections/recipe_collection_screen/recipe_collection_screen.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:flutter_recipes/screens/collections/recipe_collection_screen/recipe_collection_list_view.dart';
import 'package:flutter_recipes/screens/account/signin_screen.dart';
import 'package:flutter_recipes/services/business/ad_service.dart';
import 'package:flutter_recipes/services/firebase/firestore_service.dart'; // Added this import
import 'package:flutter_recipes/services/user_input_service.dart'; // Add this import
import 'package:flutter_recipes/shared/nav/bottom_nav.dart';
import 'package:flutter_recipes/shared/keys/global_keys.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LoadingState { idle, loadingWithAd, loadingNoAd, tutorial }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AdService adService = AdService();
  final FirestoreService firestoreService = FirestoreService();
  final UserInputService userInputService = UserInputService();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final UserModel? user = userProvider.user;

    if (user == null) {
      return _buildSignInScreen();
    } else {
      return _buildRecipeCollectionScreen(context, userProvider);
    }
  }

  Widget _buildSignInScreen() {
    return SignInScreen();
  }

  Widget _buildRecipeCollectionScreen(
      BuildContext context, UserProvider userProvider) {
    return RecipeCollectionScreen();
  }
}
