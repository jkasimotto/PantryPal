import 'package:flutter/material.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_filter_provider.dart';
import 'package:flutter_recipes/shared/progress/clock_thumb_shape.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class RecipeCollectionBottomSheetFilter extends StatefulWidget {
  final RecipeFilterProvider recipeFilterProvider;

  const RecipeCollectionBottomSheetFilter(
      {super.key, required this.recipeFilterProvider});

  @override
  _RecipeCollectionBottomSheetFilterState createState() =>
      _RecipeCollectionBottomSheetFilterState();
}

class _RecipeCollectionBottomSheetFilterState
    extends State<RecipeCollectionBottomSheetFilter> {
  double height = 54.0; // initial height

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var primaryColorLighter =
        colorScheme.primary.withOpacity(0.7); // Adjust the opacity as needed

    return GestureDetector(
      onVerticalDragUpdate: (DragUpdateDetails details) {
        setState(() {
          height -= details.delta.dy;
          height = max(18.0, min(height, 500.0)); // min and max height
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        height: height,
        decoration: BoxDecoration(
          color: primaryColorLighter,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight:
                  Radius.circular(25.0)), // Set the radius for the corners
        ),
        child: Column(
          children: [
            RecipeCollectionBottomSheetTab(color: colorScheme.onSurface),
            RecipeCollectionBottomSheetFilterSearch(
                recipeFilterProvider: widget.recipeFilterProvider,
                color: colorScheme.surface),
            RecipeCollectionBottomSheetFilterTime(
                recipeFilterProvider: widget.recipeFilterProvider),
            RecipeCollectionBottomSheetFilterIngredients(
                recipeFilterProvider: widget.recipeFilterProvider),
          ],
        ),
      ),
    );
  }
}

class RecipeCollectionBottomSheetTab extends StatelessWidget {
  final Color color;

  const RecipeCollectionBottomSheetTab({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40.0,
        height: 4.0,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        ),
      ),
    );
  }
}

class RecipeCollectionBottomSheetFilterSearch extends StatelessWidget {
  final RecipeFilterProvider recipeFilterProvider;
  final Color color;

  const RecipeCollectionBottomSheetFilterSearch(
      {required this.recipeFilterProvider, required this.color});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        filled: true,
        fillColor: color,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      onChanged: (value) {
        recipeFilterProvider.setSearchQuery(value);
      },
    );
  }
}

class RecipeCollectionBottomSheetFilterTime extends StatelessWidget {
  final RecipeFilterProvider recipeFilterProvider;

  const RecipeCollectionBottomSheetFilterTime(
      {required this.recipeFilterProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: Consumer<RecipeFilterProvider>(
        builder: (context, recipeFilterProvider, child) {
          return Row(
            children: [
              SizedBox(width: 80, child: Text('Time')), // Fixed width for label
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackShape: const RectangularSliderTrackShape(),
                    trackHeight: 4.0,
                    thumbShape: ClockThumbShape(thumbRadius: 16.0),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 28.0),
                  ),
                  child: Slider(
                    value: recipeFilterProvider.minutesRequired.toDouble(),
                    min: 0,
                    max: 180,
                    divisions: 180,
                    label: '⏱️ ${recipeFilterProvider.minutesRequired} minutes',
                    onChanged: (double newValue) {
                      recipeFilterProvider.setMinutesRequired(newValue.toInt());
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ValueThumbShape extends SliderComponentShape {
  final double thumbRadius;

  const ValueThumbShape({this.thumbRadius = 12.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Draw the thumb as a circle
    final paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, paint);

    // Draw the text inside the thumb
    String thumbLabel = ((value * 10).toInt() + 1).toString();
    thumbLabel = thumbLabel == '11' ? '10+' : thumbLabel;
    TextSpan span = TextSpan(style: labelPainter.text!.style, text: thumbLabel);
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
      canvas,
      center - Offset(tp.width / 2, tp.height / 2),
    );
  }
}

class RecipeCollectionBottomSheetFilterIngredients extends StatelessWidget {
  final RecipeFilterProvider recipeFilterProvider;

  const RecipeCollectionBottomSheetFilterIngredients(
      {required this.recipeFilterProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: Consumer<RecipeFilterProvider>(
        builder: (context, recipeFilterProvider, child) {
          return Row(
            children: [
              SizedBox(
                  width: 80,
                  child: Text('Ingredients')), // Fixed width for label
              Expanded(
                child: SliderTheme(
                  data: const SliderThemeData(
                    trackShape: RectangularSliderTrackShape(),
                    trackHeight: 4.0,
                    thumbShape: ValueThumbShape(thumbRadius: 16.0),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                  ),
                  child: Slider(
                    value: recipeFilterProvider.ingredientsCount.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: recipeFilterProvider.ingredientsCount == 10
                        ? '10+ ingredients'
                        : '${recipeFilterProvider.ingredientsCount} ingredients',
                    onChanged: (double newValue) {
                      recipeFilterProvider
                          .setIngredientsCount(newValue.toInt());
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
