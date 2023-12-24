import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';
import 'package:flutter_recipes/models/user/user_model.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:flutter_recipes/shared/global_keys.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel? user;
  final Function(BuildContext) handleShoppingList;
  final Function() handleShare;
  final Function() handleDelete;

  const CustomAppBar({
    super.key,
    required this.user,
    required this.handleShoppingList,
    required this.handleShare,
    required this.handleDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Recipes"),
      backgroundColor: Theme.of(context).colorScheme.background,
      actions: <Widget>[
        // Use Consumer or Selector to listen to changes in selectedRecipes
        // Centered IconButton with a FontAwesome shopping cart icon
        Consumer<GlobalState>(
          builder: (context, homeScreenState, child) {
            if (homeScreenState.selectedRecipes.isNotEmpty) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Showcase(
                    key: shoppingListShowcaseKey,
                    title: 'Shopping List',
                    description: 'Combine recipes into one shopping list.',
                    child: PopupMenuButton<RecipeModel>(
                      icon: FaIcon(
                        FontAwesomeIcons.cartShopping,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      itemBuilder: (context) {
                        var items = homeScreenState.selectedRecipes.values
                            .map((recipe) {
                          return PopupMenuItem<RecipeModel>(
                            value: recipe,
                            child: RecipeDropdownItem(recipe: recipe),
                          );
                        }).toList();

                        items.add(
                          PopupMenuItem<RecipeModel>(
                            child: ElevatedButton(
                              onPressed: () => handleShoppingList(context),
                              child: const Text('Create Shopping List'),
                            ),
                          ),
                        );

                        return items;
                      },
                    ),
                  ),
                  Showcase(
                    key: shareButtonShowcaseKey,
                    title: 'Share',
                    description: 'Copy recipes to send to friends',
                    child: IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.shareNodes,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      onPressed: () => handleShare(),
                    ),
                  ),
                  IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.trash,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text(
                                'Are you sure you want to delete this?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Delete'),
                                onPressed: () {
                                  handleDelete();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            } else {
              return const SizedBox
                  .shrink(); // Return an empty widget if no recipes are selected
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class RecipeDropdownItem extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeDropdownItem({super.key, required this.recipe});

  @override
  // ignore: library_private_types_in_public_api
  _RecipeDropdownItemState createState() => _RecipeDropdownItemState();
}

class _RecipeDropdownItemState extends State<RecipeDropdownItem> {
  late ValueNotifier<int> servings;

  @override
  void initState() {
    super.initState();
    GlobalState globalState = Provider.of<GlobalState>(context, listen: false);
    servings = ValueNotifier<int>(
        globalState.selectedRecipesServings[widget.recipe.metadata.id] ??
            widget.recipe.data.servings);
  }

  @override
  Widget build(BuildContext context) {
    GlobalState globalState = Provider.of<GlobalState>(context);
    return ListTile(
      title: Text(widget.recipe.data.title),
      subtitle: Text(
          'Serves: ${globalState.selectedRecipesServings[widget.recipe.metadata.id] ?? servings.value}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              if (servings.value > 1) {
                servings.value--;
                globalState.updateSelectedRecipeServings(
                    widget.recipe.metadata.id, servings.value);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              servings.value++;
              globalState.updateSelectedRecipeServings(
                  widget.recipe.metadata.id, servings.value);
            },
          ),
        ],
      ),
    );
  }
}
