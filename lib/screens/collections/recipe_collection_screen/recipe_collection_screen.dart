// lib/screens/home_screen/recipe_collection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/user/user_model.dart';
import 'package:flutter_recipes/providers/ui/nav_provider.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_filter_provider.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_provider.dart';
import 'package:flutter_recipes/providers/models/recipes/selected_recipes_provider.dart';
import 'package:flutter_recipes/providers/ui/showcaseview_provider.dart';
import 'package:flutter_recipes/providers/ui/ui_provider.dart';
import 'package:flutter_recipes/providers/models/user/user_provider.dart';
import 'package:flutter_recipes/screens/collections/recipe_collection_screen/recipe_collection_app_bar.dart';
import 'package:flutter_recipes/screens/collections/recipe_collection_screen/recipe_collection_bottom_sheet_filter.dart';
import 'package:flutter_recipes/screens/collections/recipe_collection_screen/recipe_collection_bottom_sheet_add_recipe.dart';
import 'package:flutter_recipes/screens/collections/recipe_collection_screen/recipe_collection_fab.dart';
import 'package:flutter_recipes/services/business/ad_service.dart';
import 'package:flutter_recipes/services/firebase/firestore_service.dart';
import 'package:flutter_recipes/services/business/recipe_service.dart';
import 'package:flutter_recipes/services/business/recipe_to_shopping_list_service.dart';
import 'package:flutter_recipes/services/user_input_service.dart';
import 'package:flutter_recipes/screens/collections/recipe_collection_screen/recipe_collection_list_view.dart';
import 'package:flutter_recipes/shared/nav/bottom_nav.dart';
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
        floatingActionButton:
            RecipeCollectionFAB(userInputService: userInputService),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        bottomNavigationBar: BottomNavBar(),
        bottomSheet: RecipeCollectionBottomSheet(
          userProvider: userProvider,
          userInputService: userInputService,
        ));
  }

  void _handleShoppingList(BuildContext context) {
    Provider.of<NavProvider>(context, listen: false)
        .navigateToListScreen(context);
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
    final ShowcaseProvider showcaseProvider =
        Provider.of<ShowcaseProvider>(context);

    // Avoid circular rebuild
    if (recipeProvider.recipes.value.isEmpty) {
      await recipeService.createInitialRecipes(
          userModel.id, FirestoreService());
      selectedRecipeProvider.selectDefaultRecipesWhenAvailable();
      // Start the first showcase as soon as the recipe collection screen is built.
      if (context.mounted) {
        showcaseProvider.nextShowcase(context);
      }
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

class RecipeCollectionBottomSheet extends StatelessWidget {
  final UserProvider userProvider;
  final UserInputService userInputService;

  RecipeCollectionBottomSheet({
    required this.userProvider,
    required this.userInputService,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UIProvider>(
      builder: (context, uiProvider, child) {
        return uiProvider.isAddingOrSearchingRecipes
            ? RecipeCollectionBottomSheetAddRecipe(
                userProvider: userProvider,
                userInputService: userInputService,
              )
            : RecipeCollectionBottomSheetFilter(
                recipeFilterProvider:
                    Provider.of<RecipeFilterProvider>(context),
              );
      },
    );
  }
}
