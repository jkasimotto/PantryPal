import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_model.dart';
import 'package:flutter_recipes/models/shopping_list/shopping_list_model.dart';
import 'package:flutter_recipes/providers/models/shopping_lists/shopping_list_provider.dart';
import 'package:flutter_recipes/shared/ingredients/view_ingredient_compact_card.dart';
import 'package:flutter_recipes/shared/ingredients/view_ingredient_grid_card.dart';
import 'package:provider/provider.dart';

enum IngredientView { compact, grid, plainText }

class ShoppingListDocScreen extends StatefulWidget {
  final ShoppingList shoppingList;

  const ShoppingListDocScreen({Key? key, required this.shoppingList})
      : super(key: key);

  @override
  _ShoppingListDocScreenState createState() => _ShoppingListDocScreenState();
}

class _ShoppingListDocScreenState extends State<ShoppingListDocScreen> {
  IngredientView _currentView = IngredientView.compact;
  late ValueNotifier<ShoppingList> _listNotifier;

  @override
  void initState() {
    super.initState();
    _listNotifier =
        Provider.of<ShoppingListProvider>(context, listen: false).listNotifier;
  }

  void _toggleView() {
    setState(() {
      _currentView = IngredientView
          .values[(_currentView.index + 1) % IngredientView.values.length];
    });
  }

  void _copyToClipboard() {
    final ingredientsText = widget.shoppingList.ingredients
        .map((i) => '${i.quantity.amount} ${i.quantity.units} ${i.name}')
        .join('\n');
    Clipboard.setData(ClipboardData(text: ingredientsText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shopping list copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _listNotifier,
        builder: (context, ShoppingList updatedList, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Shopping List Details'),
              backgroundColor: Theme.of(context)
                  .primaryColor, // Set AppBar color to primary theme color
              actions: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _copyToClipboard, // Copy to clipboard action
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Delete shopping list action
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  ListInfoCard(recipeTitles: updatedList.recipeTitles),
                  IngredientListCard(
                      ingredients: updatedList.ingredients,
                      onCopy: _copyToClipboard,
                      onToggleView: _toggleView,
                      currentView: _currentView),
                  // Add more cards if needed for additional details
                ],
              ),
            ),
          );
        });
  }
}

class ListInfoCard extends StatelessWidget {
  final List<String> recipeTitles;

  const ListInfoCard({Key? key, required this.recipeTitles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recipes in this list:',
                style: Theme.of(context).textTheme.titleLarge),
            ...recipeTitles.map((title) => Text(title)).toList(),
          ],
        ),
      ),
    );
  }
}

class IngredientListCard extends StatelessWidget {
  final List<ShoppingListIngredient> ingredients;
  final VoidCallback onCopy;
  final VoidCallback onToggleView;
  final IngredientView currentView;

  const IngredientListCard(
      {Key? key,
      required this.ingredients,
      required this.onCopy,
      required this.onToggleView,
      required this.currentView})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort ingredients by location and filter out empty locations
    final sortedIngredients = ingredients
      ..sort((a, b) => a.location.toString().compareTo(b.location.toString()));

    Widget view;
    switch (currentView) {
      case IngredientView.compact:
        view = CompactIngredientView(ingredients: sortedIngredients);
        break;
      case IngredientView.grid:
        view = GridIngredientView(ingredients: sortedIngredients);
        break;
      case IngredientView.plainText:
        view = PlainTextIngredientView(ingredients: sortedIngredients);
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ingredients:',
                    style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: onCopy,
                ),
                IconButton(
                  icon: const Icon(Icons.view_compact),
                  onPressed: onToggleView,
                ),
              ],
            ),
            view,
          ],
        ),
      ),
    );
  }
}

class CompactIngredientView extends StatelessWidget {
  final List<ShoppingListIngredient> ingredients;

  const CompactIngredientView({Key? key, required this.ingredients})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        return ViewIngredientCompactCard(
          ingredient: ingredients[index],
        );
      },
    );
  }
}

class GridIngredientView extends StatelessWidget {
  final List<ShoppingListIngredient> ingredients;

  const GridIngredientView({Key? key, required this.ingredients})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: ingredients
          .map((ingredient) => ViewIngredientGridCard(ingredient: ingredient))
          .toList(),
    );
  }
}

class PlainTextIngredientView extends StatelessWidget {
  final List<ShoppingListIngredient> ingredients;

  const PlainTextIngredientView({Key? key, required this.ingredients})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      maxLines: null,
      controller: TextEditingController(
        text: ingredients
            .map((ingredient) =>
                '${ingredient.quantity.amount} ${ingredient.quantity.units} ${ingredient.name}')
            .join('\n'),
      ),
    );
  }
}
