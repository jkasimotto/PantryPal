import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter_recipes/services/firebase/firebase_cache_service.dart';
import 'package:flutter_recipes/shared/ingredients/ingredient_icon.dart';
import 'package:photo_view/photo_view.dart'; // New import

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/method/recipe_method_step_model.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_provider.dart';
import 'package:flutter_recipes/providers/models/user/user_provider.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_app_bar.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_card_details.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_card_ingredients.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_card_method.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_card_notes.dart';
import 'package:flutter_recipes/screens/docs/recipe_doc_screen/recipe_doc_controller.dart';
import 'package:flutter_recipes/services/business/ad_service.dart';
import 'package:flutter_recipes/services/business/recipe_service.dart';
import 'package:flutter_recipes/services/firebase/firestore_service.dart';
import 'package:flutter_recipes/services/firebase/storage_service.dart';
import 'package:flutter_recipes/services/user_input_service.dart';
import 'package:flutter_recipes/shared/grid/draggable_grid.dart';
import 'package:flutter_recipes/shared/image/image_thumbnail.dart'; // New import
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class RecipeDocScreen extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeDocScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RecipeDocScreenState createState() => _RecipeDocScreenState();
}

class _RecipeDocScreenState extends State<RecipeDocScreen> {
  final _firestoreService = FirestoreService();
  late RecipeDocController _recipeController;
  late List<RecipeMethodStepData> _methodSteps;
  late ValueNotifier<RecipeModel> _recipeNotifier;

  @override
  void initState() {
    super.initState();
    _recipeController = RecipeDocController(widget.recipe);
    _methodSteps = widget.recipe.method;
    _recipeNotifier =
        Provider.of<RecipeProvider>(context, listen: false).recipeNotifier;
  }

  @override
  void dispose() {
    _recipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RecipeService recipeService = RecipeService(
        firestoreService: FirestoreService(),
        userProvider: Provider.of<UserProvider>(context),
        adService: Provider.of<AdService>(context),
        recipeProvider: Provider.of<RecipeProvider>(context),
        storageService: StorageService());
    developer.log('Building RecipeDocScreen', name: 'RecipeDocScreenBuilder');
    return ValueListenableBuilder(
        valueListenable: _recipeNotifier,
        builder:
            (BuildContext context, RecipeModel updatedRecipe, Widget? child) {
          developer.log('ValueListenableBuilder triggered',
              name: 'ValueListenableBuilderTrigger');
          return Scaffold(
            appBar: RecipeDocAppBar(_saveRecipe),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  buildRecipeDocDetailsCard(updatedRecipe),
                  buildRecipeDocIngredientListCard(updatedRecipe),
                  buildRecipeDocMethodListCard(updatedRecipe),
                  buildRecipeDocNotesCard(updatedRecipe),
                  buildImageGrid(
                      recipeService, updatedRecipe), // Added this line
                ],
              ),
            ),
          );
        });
  }

  Widget buildRecipeDocDetailsCard(RecipeModel updatedRecipe) {
    return RecipeDocDetailsCard(
      titleController: _recipeController.titleController,
      prepTimeController: _recipeController.prepTimeController,
      cookTimeController: _recipeController.cookTimeController,
      cuisineController: _recipeController.cuisineController,
      courseController: _recipeController.courseController,
      servingsController: _recipeController.servingsController,
    );
  }

  Widget buildRecipeDocIngredientListCard(RecipeModel updatedRecipe) {
    return RecipeDocCardIngredients(
      recipe: updatedRecipe,
      recipeController: _recipeController,
      saveRecipe: _saveRecipe,
    );
  }

  Widget buildRecipeDocMethodListCard(RecipeModel updatedRecipe) {
    return RecipeDocCardMethod(
      methodSteps: _methodSteps,
      methodControllers: _recipeController.methodControllers,
    );
  }

  Widget buildRecipeDocNotesCard(RecipeModel updatedRecipe) {
    return RecipeDocCardNotes(
      notesController: _recipeController.notesController,
    );
  }

  Widget buildImageGrid(
      RecipeService recipeService, RecipeModel updatedRecipe) {
    // Define image thumbnail sizes
    const double imageThumbnailWidth = 100.0;
    const double imageThumbnailHeight = 100.0;

    // Define grid count
    const int gridCount = 3;

    // Calculate grid height
    final int numberOfImages = updatedRecipe.firebaseImagePaths.length +
        1; // +1 for the add image thumbnail
    final int numberOfRows = (numberOfImages / gridCount).ceil();
    final double gridHeight = numberOfRows * imageThumbnailHeight;

    developer.log('Building ImageGrid', name: 'ImageGridBuilder');

    final items = [
      ...updatedRecipe.firebaseImagePaths.map((path) {
        developer.log('Building ImageThumbnail for path: $path',
            name: 'ImageThumbnailBuilder');

        return ImageThumbnail(
          firebaseImagePath: path,
          width: imageThumbnailWidth,
          height: imageThumbnailHeight,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return FutureBuilder<ImageProvider>(
                    future: FirebaseCacheService().getImageProvider(path),
                    builder: (BuildContext context,
                        AsyncSnapshot<ImageProvider> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return Scaffold(
                          backgroundColor: Colors.black,
                          appBar: AppBar(
                            backgroundColor: Colors.transparent,
                            leading: IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          body: Center(
                            child: PhotoView(
                              imageProvider: snapshot.data,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            );
          },
        );
      }).toList(),
      buildAddImageThumbnail(recipeService)
    ]; // Add the add image thumbnail

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: gridHeight,
        child: DraggableGrid(
          items: items,
          onReorder: (oldIndex, newIndex) {
            developer.log('Reordering images', name: 'ImageReorder');
            setState(() {
              updatedRecipe = updatedRecipe.reorderImages(oldIndex, newIndex);
              _firestoreService.updateDocument(updatedRecipe, 'recipes');
            });
          },
          crossAxisCount: gridCount,
        ),
      ),
    );
  }

  Widget buildAddImageThumbnail(RecipeService recipeService) {
    developer.log('Building AddImageThumbnail',
        name: 'AddImageThumbnailBuilder');
    return GestureDetector(
      onTap: () async {
        UserInputService userInputService = UserInputService();
        List<XFile>? images =
            await userInputService.showImageSourceSelection(context);
        if (images != null) {
          for (var image in images) {
            developer.log('Adding image to recipe: ${image.path}',
                name: 'ImageAdder');

            recipeService.addImagePathToRecipe(widget.recipe, File(image.path));
          }
        }
      },
      child: ImageThumbnail(
        icon: Icons.add,
        width: 100.0,
        height: 100.0,
      ),
    );
  }

  void saveRecipeAndCloseDialog() {
    _saveRecipe(shouldShowDialog: false);
    Navigator.of(context).pop();
  }

  void _saveRecipe({bool shouldShowDialog = true}) {
    RecipeModel updatedRecipe = updateRecipe();

    _firestoreService.updateDocument(updatedRecipe, 'recipes').then((_) {
      if (kDebugMode) {
        print('Recipe updated in Firestore');
      }
      if (shouldShowDialog) {
        showSuccessDialog();
      }
    }).catchError((error) {
      handleError(error);
    });
  }

  RecipeModel updateRecipe() {
    return widget.recipe.copyWith(
      title: _recipeController.titleController.text,
      cuisine: _recipeController.cuisineController.text,
      course: _recipeController.courseController.text,
      servings: int.parse(_recipeController.servingsController.text),
      prepTime: int.parse(_recipeController.prepTimeController.text),
      cookTime: int.parse(_recipeController.cookTimeController.text),
      notes: _recipeController.notesController.text,
    );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Recipe updated successfully'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void handleError(error) {
    if (kDebugMode) {
      print('Failed to update recipe: $error');
    }
    return null;
  }
}
