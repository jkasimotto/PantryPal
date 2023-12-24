import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_recipes/models/shopping_list/shopping_list_model.dart';

enum IngredientView { compact, grid, plainText }

class ListDetailScreen extends StatefulWidget {
  final ShoppingListModel shoppingList;

  const ListDetailScreen({Key? key, required this.shoppingList})
      : super(key: key);

  @override
  _ListDetailScreenState createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  IngredientView _currentView = IngredientView.compact;

  void _toggleView() {
    setState(() {
      _currentView = IngredientView
          .values[(_currentView.index + 1) % IngredientView.values.length];
    });
  }

  void _copyToClipboard() {
    final ingredientsText = widget.shoppingList.data.ingredients
        .map((i) => '${i.quantity} ${i.units} ${i.ingredientName}')
        .join('\n');
    Clipboard.setData(ClipboardData(text: ingredientsText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shopping list copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen if needed
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            ListInfoCard(recipeTitles: widget.shoppingList.data.recipeTitles),
            IngredientListCard(
                ingredients: widget.shoppingList.data.ingredients,
                onCopy: _copyToClipboard,
                onToggleView: _toggleView,
                currentView: _currentView),
            // Add more cards if needed for additional details
          ],
        ),
      ),
    );
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
  final List<ShoppingListIngredientData> ingredients;
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

Widget buildIngredientIcon(String name) {
  return SizedBox(
    width: 50,
    child: Image.asset('assets/images/food/${name.toLowerCase()}.png',
        errorBuilder: (context, error, stackTrace) {
      if (name.endsWith('s')) {
        return Image.asset(
            'assets/images/food/${name.toLowerCase().substring(0, name.length - 1)}.png',
            errorBuilder: (context, error, stackTrace) => Container());
      } else {
        return Container();
      }
    }),
  );
}

class CompactIngredientView extends StatelessWidget {
  final List<ShoppingListIngredientData> ingredients;

  const CompactIngredientView({Key? key, required this.ingredients})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        var ingredient = ingredients[index];
        var unit = (ingredient.units == 'item' || ingredient.units == 'items')
            ? ''
            : ingredient.units;
        return Card(
          child: ListTile(
            leading: buildIngredientIcon(ingredient.ingredientName),
            title: Text(ingredient.ingredientName),
            subtitle: Text('${ingredient.quantity} $unit'),
          ),
        );
      },
    );
  }
}

class GridIngredientView extends StatelessWidget {
  final List<ShoppingListIngredientData> ingredients;

  const GridIngredientView({Key? key, required this.ingredients})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: ingredients
          .map((ingredient) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                          '${ingredient.ingredientName}\n${ingredient.quantity} ${ingredient.units}',
                          style: const TextStyle(fontSize: 12)),
                      Expanded(
                        child: buildIngredientIcon(ingredient.ingredientName),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class PlainTextIngredientView extends StatelessWidget {
  final List<ShoppingListIngredientData> ingredients;

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
                '${ingredient.quantity} ${ingredient.units} ${ingredient.ingredientName}')
            .join('\n'),
      ),
    );
  }
}
