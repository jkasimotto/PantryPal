import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/user/user_model.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_provider.dart';
import 'package:flutter_recipes/providers/ui/showcaseview_provider.dart';
import 'package:flutter_recipes/providers/models/user/user_provider.dart';
import 'package:flutter_recipes/shared/dialogs/cookbook_input_dialog.dart';
import 'package:flutter_recipes/services/business/ad_service.dart';
import 'package:flutter_recipes/services/firebase/firestore_service.dart';
import 'package:flutter_recipes/services/business/recipe_service.dart';
import 'package:flutter_recipes/services/user_input_service.dart';
import 'package:flutter_recipes/shared/keys/global_keys.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:flutter_recipes/shared/transcription/transcription_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class RecipeCollectionBottomSheetAddRecipe extends StatelessWidget {
  final UserProvider userProvider;
  final UserInputService userInputService;
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 20.0); // Add this line

  RecipeCollectionBottomSheetAddRecipe({
    super.key,
    required this.userProvider,
    required this.userInputService,
  });

  @override
  Widget build(BuildContext context) {
    UserModel? user = userProvider.user;
    final RecipeService recipeService = RecipeService(
        firestoreService: FirestoreService(),
        userProvider: userProvider,
        adService: Provider.of<AdService>(context),
        recipeProvider: Provider.of<RecipeProvider>(context));

    // Get showcase provider
    if (user != null && user.metadata.signInCount == 0) {
      final ShowcaseProvider showcaseProvider =
          Provider.of<ShowcaseProvider>(context);
      showcaseProvider.nextShowcase(context);
    }

    if (user == null) {
      throw Exception('User is null');
    }

    var isBottomSheetVisible =
        Provider.of<GlobalState>(context).isBottomSheetVisible;
    if (!isBottomSheetVisible) {
      return const SizedBox.shrink();
    }

    var colorScheme = Theme.of(context).colorScheme;
    var primaryColorLighter = colorScheme.primary.withOpacity(0.7);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25.0),
        topRight: Radius.circular(25.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: primaryColorLighter, // set the color to primaryColorLighter
        ),
        height: 116, // reduce the height of the container to 120
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Showcase(
          key: recipeCollectionBottomSheetAddListView,
          description:
              'Type, speak, enter a website url or photograph your cookbook to add recipes',
          child: ListView(
            controller: _scrollController, // Add this line
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              _buildActionTile(
                context,
                icon: FontAwesomeIcons.solidKeyboard,
                label: 'Type',
                onTap: () async {
                  final recipeText = await userInputService.selectRecipeText(
                      context, user.metadata.hasCompletedTextAction);
                  if (recipeText != null) {
                    if (context.mounted) {
                      recipeService.extractRecipeFromText(recipeText);
                    }
                  }
                },
              ),
              _buildActionTile(
                context,
                icon: FontAwesomeIcons.microphone,
                label: 'Speak',
                onTap: () async {
                  showDialog(
                      context: context,
                      builder: (context) => TranscriptionDialog());
                  final recipeText = await userInputService.selectRecipeText(
                      context, user.metadata.hasCompletedTextAction);
                  if (recipeText != null) {
                    if (context.mounted) {
                      recipeService.extractRecipeFromText(recipeText);
                    }
                  }
                },
              ),
              _buildActionTile(
                context,
                icon: FontAwesomeIcons.google,
                label: 'Website',
                onTap: () async {
                  final url = await userInputService.selectUrl(
                      context, user.metadata.hasCompletedWebAction);
                  if (url != null) {
                    recipeService.extractRecipeFromWebUrl(url);
                  }
                },
              ),
              _buildActionTile(
                context,
                icon: FontAwesomeIcons.bookOpen,
                label: 'Cookbook',
                onTap: () async {
                  final mediaList = await showDialog<Map<String, List<XFile?>>>(
                    context: context,
                    builder: (context) =>
                        CookbookInputDialog(userInputService: userInputService),
                  );
                  // final mediaList =
                  //     await userInputService.showImageSourceSelection(context);
                  if (mediaList != null) {
                    recipeService.extractRecipeFromImages(
                      mediaList.values
                          .expand((element) => element)
                          .where((element) => element != null)
                          .toList()
                          .cast<XFile>(),
                    );
                  }
                },
              ),
              _buildActionTile(
                context,
                icon: FontAwesomeIcons.utensils,
                label: 'Photo',
                onTap: () async {
                  final mediaList =
                      await userInputService.showImageSourceSelection(context);
                  if (mediaList != null) {
                    recipeService.extractRecipeFromImages(mediaList);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100, // reduced the height of the card to 100
        width: 100, // reduced the width of the card to 100
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(4), // Reduced margin
        padding: const EdgeInsets.symmetric(
            vertical: 16, horizontal: 16), // Adjusted padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FaIcon(icon,
                size: 35.0, // reduced the icon size to 35.0
                color: Theme.of(context)
                    .colorScheme
                    .onSurface), // Increased icon size
            const SizedBox(height: 8), // Increased space between icon and text
            Text(label, style: const TextStyle(fontSize: 12.0)),
          ],
        ),
      ),
    );
  }
}
