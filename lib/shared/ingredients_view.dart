import 'package:flutter/material.dart';
import 'package:flutter_recipes/shared/ingredient_icon.dart';

class Ingredient {
  final String name;
  final String units;
  final double quantity;
  final String iconPath;

  Ingredient({
    required this.name,
    required this.units,
    required this.quantity,
    required this.iconPath,
  });
}

class GenericCompactIngredientView extends StatelessWidget {
  final List<Ingredient> ingredients;

  const GenericCompactIngredientView({Key? key, required this.ingredients})
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
            leading: buildIngredientIcon(ingredient.iconPath),
            title: Text(ingredient.name),
            subtitle: Text('${ingredient.quantity} $unit'),
          ),
        );
      },
    );
  }
}

class GenericGridIngredientView extends StatelessWidget {
  final List<Ingredient> ingredients;

  const GenericGridIngredientView({Key? key, required this.ingredients})
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
                          '${ingredient.name}\n${ingredient.quantity} ${ingredient.units}',
                          style: const TextStyle(fontSize: 12)),
                      Expanded(
                        child: buildIngredientIcon(ingredient.iconPath),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class GenericPlainTextIngredientView extends StatelessWidget {
  final List<Ingredient> ingredients;

  const GenericPlainTextIngredientView({Key? key, required this.ingredients})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      maxLines: null,
      controller: TextEditingController(
        text: ingredients
            .map((ingredient) =>
                '${ingredient.quantity} ${ingredient.units} ${ingredient.name}')
            .join('\n'),
      ),
    );
  }
}
