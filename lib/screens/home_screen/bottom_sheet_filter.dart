import 'package:flutter/material.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class BottomSheetFilter extends StatelessWidget {
  final GlobalState homeScreenState;

  const BottomSheetFilter({super.key, required this.homeScreenState});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var primaryColorLighter =
        colorScheme.primary.withOpacity(0.7); // Adjust the opacity as needed
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 132,
      decoration: BoxDecoration(
        color: primaryColorLighter,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0)), // Set the radius for the corners
      ),
      child: Column(
        children: [
          if (homeScreenState.isBottomSheetVisible) ...[
            Padding(
              padding: const EdgeInsets.only(right: 60.0),
              child: Consumer<GlobalState>(
                builder: (context, homeScreenState, child) {
                  return SliderTheme(
                    data: SliderThemeData(
                      trackShape: const RectangularSliderTrackShape(),
                      trackHeight: 4.0,
                      thumbShape: ClockThumbShape(thumbRadius: 12.0),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 28.0),
                    ),
                    child: Slider(
                      value: homeScreenState.minutesRequired.toDouble(),
                      min: 0,
                      max: 180,
                      divisions: 180,
                      label: '⏱️ ${homeScreenState.minutesRequired} minutes',
                      onChanged: (double newValue) {
                        homeScreenState.setMinutesRequired(newValue.toInt());
                      },
                    ),
                  );
                },
              ),
            ),
          ],
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
              homeScreenState.setSearchQuery(value);
            },
          ),
        ],
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
