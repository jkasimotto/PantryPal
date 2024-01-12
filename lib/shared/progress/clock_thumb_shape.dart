import 'dart:math';
import 'package:flutter/material.dart';

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
