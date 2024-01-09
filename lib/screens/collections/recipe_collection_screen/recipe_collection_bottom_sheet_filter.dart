import 'package:flutter/material.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_filter_provider.dart';
import 'package:flutter_recipes/shared/global_state.dart';
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
  double height = 132.0; // initial height

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var primaryColorLighter =
        colorScheme.primary.withOpacity(0.7); // Adjust the opacity as needed

    return GestureDetector(
      onVerticalDragUpdate: (DragUpdateDetails details) {
        setState(() {
          height -= details.delta.dy;
          height = max(132.0, min(height, 500.0)); // min and max height
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
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                margin: EdgeInsets.only(top: 8.0),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
            ),
            if (height >= 200.0) ...[
              Text(
                'Filter by',
                style: TextStyle(color: colorScheme.onSurface, fontSize: 20.0),
              )
            ],
            Padding(
              padding: const EdgeInsets.only(right: 60.0),
              child: Consumer<RecipeFilterProvider>(
                builder: (context, recipeFilterProvider, child) {
                  return SliderTheme(
                    data: SliderThemeData(
                      trackShape: const RectangularSliderTrackShape(),
                      trackHeight: 4.0,
                      thumbShape: ClockThumbShape(thumbRadius: 12.0),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 28.0),
                    ),
                    child: Slider(
                      value: recipeFilterProvider.minutesRequired.toDouble(),
                      min: 0,
                      max: 180,
                      divisions: 180,
                      label:
                          '⏱️ ${recipeFilterProvider.minutesRequired} minutes',
                      onChanged: (double newValue) {
                        recipeFilterProvider
                            .setMinutesRequired(newValue.toInt());
                      },
                    ),
                  );
                },
              ),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: colorScheme.onSurface),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: colorScheme.onSurface),
              onChanged: (value) {
                widget.recipeFilterProvider.setSearchQuery(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ClockThumbShape extends SliderComponentShape {
  final double thumbRadius;

  ClockThumbShape({this.thumbRadius = 12.0});

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
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Draw the clock circle
    final paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, paint);

    // Calculate the angle for the hour and minute hands
    // We'll assume that the slider value represents minutes
    final minutes = value * 180;
    final hourAngle = 2 * pi * (minutes / 60 / 12);
    final minuteAngle = 2 * pi * (minutes / 60);

    // Draw the clock hands
    final handPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center,
      center +
          Offset(cos(hourAngle - pi / 2) * thumbRadius / 2,
              sin(hourAngle - pi / 2) * thumbRadius / 2),
      handPaint,
    );
    canvas.drawLine(
      center,
      center +
          Offset(cos(minuteAngle - pi / 2) * thumbRadius / 2,
              sin(minuteAngle - pi / 2) * thumbRadius / 2),
      handPaint,
    );
  }
}
