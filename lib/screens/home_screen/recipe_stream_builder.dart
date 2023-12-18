import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe_model.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:flutter_recipes/screens/home_screen/recipe_list_view.dart';
import 'package:provider/provider.dart';

class RecipeStreamBuilder extends StatelessWidget {
  final Stream<List<RecipeModel>> stream;
  final String userId;

  RecipeStreamBuilder({super.key, required this.stream, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RecipeModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          developer.log('StreamBuilder: No data');
          return const Center(child: CircularProgressIndicator());
        } else {
          List<RecipeModel> recipes = snapshot.data!;
          developer
              .log('StreamBuilder: Received data - ${recipes.length} recipes');

          if (Provider.of<GlobalState>(context, listen: false).recipes != recipes) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<GlobalState>(context, listen: false).setRecipes(recipes);
              developer.log('StreamBuilder: Updated recipes in HomeScreenState');
            });
          }
          return const RecipeListView();
        }
      },
    );
  }
}