import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/user/user_model.dart';
import 'package:flutter_recipes/providers/user_provider.dart';
import 'package:flutter_recipes/shared/bottom_nav.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:flutter_recipes/services/ad_service.dart';
import 'package:flutter_recipes/services/firestore_service.dart';
import 'package:flutter_recipes/services/user_input_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_recipes/controllers/recipe_logic_controller.dart';
import 'package:provider/provider.dart';

class AddRecipeScreen extends StatelessWidget {
  const AddRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    UserModel? user = userProvider.user;
    UserInputService userInputService = UserInputService();
    RecipeLogicController recipeController = RecipeLogicController(
      firestoreService: FirestoreService(),
      homeScreenState: Provider.of<GlobalState>(context),
      userProvider: Provider.of<UserProvider>(context),
      adService: AdService(),
    );

    if (user == null) {
      throw Exception('User is null');
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Add padding to the GridView
        child: GridView.count(
          crossAxisCount:
              3, // Increase the number of tiles in the cross-axis direction
          childAspectRatio: 1, // Adjust the width-to-height ratio of the tiles
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
                    recipeController.extractRecipeFromText(recipeText);
                  }
                }
              },
            ),
            _buildActionTile(
              context,
              icon: FontAwesomeIcons.microphone,
              label: 'Speak',
              onTap: () async {
                final recipeText = await userInputService.selectRecipeText(
                    context, user.metadata.hasCompletedTextAction);
                if (recipeText != null) {
                  if (context.mounted) {
                    recipeController.extractRecipeFromText(recipeText);
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
                  recipeController.extractRecipeFromWebUrl(url);
                }
              },
            ),
            _buildActionTile(
              context,
              icon: FontAwesomeIcons.bookOpen,
              label: 'Cookbook',
              onTap: () async {
                final mediaList =
                    await userInputService.showImageSourceSelection(context);
                if (mediaList != null) {
                  recipeController.extractRecipeFromImages(mediaList);
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
                  recipeController.extractRecipeFromImages(mediaList);
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget _buildActionTile(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
                size: 30.0,
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
