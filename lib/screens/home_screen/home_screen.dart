// lib/screens/home_screen.dart
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_recipes/controllers/recipe_logic_controller.dart';
import 'package:flutter_recipes/models/user/user_model.dart';
import 'package:flutter_recipes/providers/ad_provider.dart';
import 'package:flutter_recipes/providers/user_provider.dart';
import 'package:flutter_recipes/providers/bottom_nav_provider.dart'; // Added this import
import 'package:flutter_recipes/screens/recipe_collection_screen.dart/recipe_collection_app_bar.dart';
import 'package:flutter_recipes/screens/home_screen/bottom_sheet_filter.dart';
import 'package:flutter_recipes/screens/home_screen/bottom_sheet_card_list.dart';
import 'package:flutter_recipes/screens/list_collection_screen/list_collection_screen.dart';
import 'package:flutter_recipes/screens/recipe_collection_screen.dart/recipe_collection_screen.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:flutter_recipes/screens/home_screen/recipe_list_view.dart';
import 'package:flutter_recipes/screens/signin_screen.dart';
import 'package:flutter_recipes/services/ad_service.dart';
import 'package:flutter_recipes/services/firestore_service.dart'; // Added this import
import 'package:flutter_recipes/services/user_input_service.dart'; // Add this import
import 'package:flutter_recipes/shared/bottom_nav.dart';
import 'package:flutter_recipes/shared/global_keys.dart';
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
