import 'dart:math' as math;

import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// S34's trend (DESIGN §3.5): an `ink` 3 px line over a `raised` area, with
/// a 5 px dot on the latest point and three `divider` rails. Gaps (null)
/// are skipped. Read as [semanticLabel].
class TrendLine extends StatelessWidget {
  const new({
    required this.values,
    required this.semanticLabel,
    this.height = 110,
    super.key,
  });

  /// 0–1, oldest first.
  final List<double?> values;
  final double height;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _TrendPainter(
            values: values,
            line: colors.ink,
            area: colors.raised,
            rail: colors.divider,
          ),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  new({
    required this.values,
    required this.line,
    required this.area,
    required this.rail,
  });

  final List<double?> values;
  final Color line;
  final Color area;
  final Color rail;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 16.0;
    final rails = Paint()
      ..color = rail
      ..strokeWidth = 1;
    for (final y in [0.1, 0.5, 0.9]) {
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * y),
        rails,
      );
    }
    final known = [for (final v in values) ?v];
    if (known.isEmpty) return;
    // Scaled to the values with room above and below, so small changes show.
    final low = math.max(0, known.reduce(math.min) - 0.1);
    final high = math.min(1, known.reduce(math.max) + 0.1);
    final span = math.max(high - low, 0.01);
    final step = values.length < 2
        ? 0.0
        : (size.width - 2 * inset) / (values.length - 1);
    final points = [
      for (final (i, v) in values.indexed)
        if (v != null)
          Offset(
            inset + step * i,
            size.height * 0.1 + size.height * 0.8 * (1 - (v - low) / span),
          ),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    final fill = Path.from(path)
      ..lineTo(points.last.dx, size.height * 0.9)
      ..lineTo(points.first.dx, size.height * 0.9)
      ..close();
    canvas
      ..drawPath(fill, Paint()..color = area)
      ..drawPath(
        path,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      )
      ..drawCircle(points.last, 5, Paint()..color = line);
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.values != values ||
      old.line != line ||
      old.area != area ||
      old.rail != rail;
}
