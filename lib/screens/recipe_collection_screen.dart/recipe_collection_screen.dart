// lib/screens/home_screen/recipe_collection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/user/user_model.dart';
import 'package:flutter_recipes/providers/ad_provider.dart';
import 'package:flutter_recipes/providers/bottom_nav_provider.dart';
import 'package:flutter_recipes/providers/recipe_provider.dart';
import 'package:flutter_recipes/providers/selected_recipes_provider.dart';
import 'package:flutter_recipes/providers/user_provider.dart';
import 'package:flutter_recipes/screens/recipe_collection_screen.dart/recipe_collection_app_bar.dart';
import 'package:flutter_recipes/screens/home_screen/bottom_sheet_filter.dart';
import 'package:flutter_recipes/screens/home_screen/bottom_sheet_card_list.dart';
import 'package:flutter_recipes/screens/list_collection_screen/list_collection_screen.dart';
import 'package:flutter_recipes/screens/recipe_collection_screen.dart/recipe_collection_fab.dart';
import 'package:flutter_recipes/services/ad_service.dart';
import 'package:flutter_recipes/services/firestore_service.dart';
import 'package:flutter_recipes/services/recipe_service.dart';
import 'package:flutter_recipes/services/recipe_to_shopping_list_service.dart';
import 'package:flutter_recipes/services/user_input_service.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:flutter_recipes/screens/home_screen/recipe_list_view.dart';
import 'package:flutter_recipes/shared/bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RecipeCollectionScreen extends StatelessWidget {
  final UserInputService userInputService = UserInputService();

  RecipeCollectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    UserModel? userModel = userProvider.user;
    if (userModel != null && userModel.metadata.signInCount == 0) {
      _handleFirstTimeSignIn(context, userModel);
    }

    return Scaffold(
        appBar: RecipeCollectionAppBar(
          user: userProvider.user,
          handleShoppingList: _handleShoppingList,
        ),
        body: const RecipeCollectionBody(),
        floatingActionButton: const RecipeCollectionFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        bottomNavigationBar: BottomNavBar(),
        bottomSheet:
            !Provider.of<GlobalState>(context).isAddingOrSearchingRecipes
                ? BottomSheetFilter(
                    homeScreenState: Provider.of<GlobalState>(context))
                : BottomSheetCardList(
                    userProvider: userProvider,
                    userInputService: userInputService,
                  ));
  }

  void _handleShoppingList(BuildContext context) {
    final bottomNavBarProvider =
        Provider.of<BottomNavBarProvider>(context, listen: false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => const ListsScreen()),
      (route) => false,
    );
    bottomNavBarProvider.currentIndex = 1;
    RecipeToListConverter(
            userProvider: Provider.of<UserProvider>(context, listen: false),
            adService: Provider.of<AdService>(context, listen: false),
            selectedRecipeProvider:
                Provider.of<SelectedRecipeProvider>(context, listen: false),
            firestoreService: FirestoreService(),
            uuid: const Uuid())
        .generateShoppingList();
  }

  Future<void> _handleFirstTimeSignIn(
      BuildContext context, UserModel userModel) async {
    // If it's the user's first time signing in, alter the GlobalState
    final AdService adService = Provider.of<AdService>(context);
    final RecipeProvider recipeProvider =
        Provider.of<RecipeProvider>(context, listen: false);
    final SelectedRecipeProvider selectedRecipeProvider =
        Provider.of<SelectedRecipeProvider>(context);
    final RecipeService recipeService = RecipeService(
        firestoreService: FirestoreService(),
        userProvider: Provider.of<UserProvider>(context),
        adService: adService,
        recipeProvider: recipeProvider);
    // Perform your operations on globalState here...

    // Avoid circular rebuild
    if (recipeProvider.recipes.value.isEmpty) {
      await recipeService.createInitialRecipes(
          userModel.id, FirestoreService());
      selectedRecipeProvider.selectDefaultRecipesWhenAvailable();
    }
  }
}

class RecipeCollectionBody extends StatelessWidget {
  const RecipeCollectionBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(
          child: RecipeCollectionListView(),
        ),
      ],
    );
  }
}
