// lib/screens/home_screen.dart
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_recipes/controllers/recipe_controller.dart';
import 'package:flutter_recipes/models/user/user_model.dart';
import 'package:flutter_recipes/providers/ad_provider.dart';
import 'package:flutter_recipes/providers/user_provider.dart';
import 'package:flutter_recipes/providers/bottom_nav_provider.dart'; // Added this import
import 'package:flutter_recipes/screens/home_screen/app_bar.dart';
import 'package:flutter_recipes/screens/home_screen/bottom_sheet_filter.dart';
import 'package:flutter_recipes/screens/home_screen/bottom_sheet_card_list.dart';
import 'package:flutter_recipes/screens/lists_screen/lists_screen.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:flutter_recipes/screens/home_screen/recipe_list_view.dart';
import 'package:flutter_recipes/screens/signin_screen.dart';
import 'package:flutter_recipes/services/ad_service.dart';
import 'package:flutter_recipes/services/firestore_service.dart'; // Added this import
import 'package:flutter_recipes/services/recipe_extraction_service.dart';
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
    final RecipeController recipeController = RecipeController(
      firestoreService: FirestoreService(),
      homeScreenState: Provider.of<GlobalState>(context),
      userProvider: Provider.of<UserProvider>(context),
      adService: Provider.of<AdProvider>(context).adService,
    );

    if (user == null) {
      return SignInScreen();
    } else {
      _showShowcase(context);
      return Consumer<BottomNavBarProvider>(
        builder: (context, bottomNavBarProvider, child) {
          return Scaffold(
              appBar: CustomAppBar(
                user: userProvider.user,
                handleDelete: () {
                  recipeController.deleteSelectedRecipes();
                },
                handleShare: () {
                  recipeController.shareSelectedRecipes();
                },
                handleShoppingList: (context) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const ListsScreen()),
                    (route) => false,
                  );
                  bottomNavBarProvider.currentIndex = 1;
                  recipeController.generateShoppingList(context);
                },
              ),
              body: const Column(
                children: [
                  Expanded(
                    child: RecipeListView(),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Provider.of<GlobalState>(context, listen: false)
                      .setAddingOrSearchingRecipes(
                          !Provider.of<GlobalState>(context, listen: false)
                              .isAddingOrSearchingRecipes);
                },
                child:
                    Provider.of<GlobalState>(context).isAddingOrSearchingRecipes
                        ? const FaIcon(FontAwesomeIcons.magnifyingGlass)
                        : const FaIcon(FontAwesomeIcons.plus),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation
                  .miniEndFloat,
              bottomNavigationBar: BottomNavBar(),
              bottomSheet:
                  !Provider.of<GlobalState>(context).isAddingOrSearchingRecipes
                      ? BottomSheetFilter(
                          homeScreenState: Provider.of<GlobalState>(context))
                      : BottomSheetCardList(
                          userProvider: userProvider,
                          userInputService: userInputService,
                          recipeController: recipeController));
        },
      );
    }
  }

  void _showShowcase(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenShowcase = prefs.getBool('hasSeenShowcase') ?? false;

    if (!hasSeenShowcase) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ShowCaseWidget.of(context).startShowCase([
          textShowcaseKey,
          websiteShowcaseKey,
          cameraShowcaseKey,
          shoppingListShowcaseKey,
          shareButtonShowcaseKey,
          filterShowcaseKey
        ]);
        await prefs.setBool('hasSeenShowcase', true);
      });
    }
  }
}
