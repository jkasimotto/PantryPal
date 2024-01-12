// lib/screens/home_screen/recipe_collection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_recipes/shared/dialogs/cookbook_input_dialog.dart';
import 'package:flutter_recipes/shared/transcription/transcription_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_recipes/providers/models/user/user_provider.dart';
import 'package:flutter_recipes/services/business/recipe_service.dart';
import 'package:flutter_recipes/services/user_input_service.dart';
import 'package:flutter_recipes/services/firebase/firestore_service.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_provider.dart';
import 'package:flutter_recipes/services/business/ad_service.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class RecipeCollectionFAB extends StatelessWidget {
  final UserInputService userInputService;

  RecipeCollectionFAB({
    Key? key,
    required this.userInputService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final recipeService = RecipeService(
        firestoreService: FirestoreService(),
        userProvider: userProvider,
        adService: Provider.of<AdService>(context),
        recipeProvider: Provider.of<RecipeProvider>(context));

    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 300,
              color: Colors.white,
              child: ListView(
                children: <Widget>[
                  _buildOptionRow(
                      context, FontAwesomeIcons.solidKeyboard, 'Type',
                      () async {
                    final recipeText = await userInputService.selectRecipeText(
                        context,
                        userProvider.user?.metadata.hasCompletedTextAction ??
                            false);
                    if (recipeText != null) {
                      if (context.mounted) {
                        recipeService.extractRecipeFromText(recipeText);
                      }
                    }
                  }),
                  _buildOptionRow(context, FontAwesomeIcons.microphone, 'Speak',
                      () async {
                    showDialog(
                        context: context,
                        builder: (context) => TranscriptionDialog());
                  }),
                  _buildOptionRow(context, FontAwesomeIcons.google, 'Website',
                      () async {
                    final url = await userInputService.selectUrl(
                        context,
                        userProvider.user?.metadata.hasCompletedWebAction ??
                            false);
                    if (url != null) {
                      recipeService.extractRecipeFromWebUrl(url);
                    }
                  }),
                  _buildOptionRow(
                      context, FontAwesomeIcons.bookOpen, 'Cookbook', () async {
                    final mediaList =
                        await showDialog<Map<String, List<XFile?>>>(
                      context: context,
                      builder: (context) => CookbookInputDialog(
                          userInputService: userInputService),
                    );
                    if (mediaList != null) {
                      recipeService.extractRecipeFromImages(
                        mediaList.values
                            .expand((element) => element)
                            .where((element) => element != null)
                            .toList()
                            .cast<XFile>(),
                      );
                    }
                  }),
                  _buildOptionRow(context, FontAwesomeIcons.utensils, 'Photo',
                      () async {
                    final mediaList = await userInputService
                        .showImageSourceSelection(context);
                    if (mediaList != null) {
                      recipeService.extractRecipeFromImages(mediaList);
                    }
                  }),
                ],
              ),
            );
          },
        );
      },
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FaIcon(FontAwesomeIcons.plus),
          Text('Add', style: TextStyle(fontSize: 10.0)),
        ],
      ),
    );
  }

  Widget _buildOptionRow(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: FaIcon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
