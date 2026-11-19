import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A ring that fills clockwise from the top with a round cap (DESIGN §7),
/// with [child] in the middle. [value] is clamped to 0–1.
class ProgressRing extends StatelessWidget {
  const new({
    required this.value,
    required this.size,
    required this.stroke,
    required this.color,
    required this.trackColor,
    required this.semanticLabel,
    this.child,
    super.key,
  });

  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Color trackColor;

  /// Read by screen readers with the values, e.g. "2 of 6 tasks done today".
  final String semanticLabel;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    excludeSemantics: true,
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: RingPainter(
          value: value.isNaN ? 0 : value.clamp(0, 1),
          stroke: stroke,
          color: color,
          trackColor: trackColor,
        ),
        child: Center(child: child),
      ),
    ),
  );
}

@visibleForTesting
class RingPainter extends CustomPainter {
  const new({
    required this.value,
    required this.stroke,
    required this.color,
    required this.trackColor,
  });

  final double value;
  final double stroke;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = trackColor);
    if (value > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(RingPainter old) =>
      old.value != value ||
      old.stroke != stroke ||
      old.color != color ||
      old.trackColor != trackColor;
}
