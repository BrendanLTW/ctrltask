import 'dart:math' as math;

import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Equal-width bars (DESIGN §7): at most 30 wide with radius 10, an
/// optional value above in 11/600 and a day below in 12/600 `muted`. The
/// [best] bar and its label are drawn stronger. Read as [semanticLabel].
class BarChart extends StatelessWidget {
  const new({
    required this.values,
    required this.labels,
    required this.color,
    required this.bestColor,
    required this.semanticLabel,
    this.best,
    this.showValues = false,
    this.height = 120,
    super.key,
  });

  final List<int> values;

  /// One per bar; empty to leave a bar unlabelled.
  final List<String> labels;
  final Color color;
  final Color bestColor;
  final int? best;
  final bool showValues;

  /// The tallest bar's height.
  final double height;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final top = values.fold(0, math.max);
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, v) in values.indexed)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showValues) ...[
                    Text(
                      '$v',
                      maxLines: 1,
                      style: text.labelSm.copyWith(
                        color: i == best ? colors.ink : colors.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  FractionallySizedBox(
                    widthFactor: 0.66,
                    child: Center(
                      child: Container(
                        width: 30,
                        // An empty day keeps a thin stub, as designed.
                        height: math.max(8, top == 0 ? 0 : height * v / top),
                        decoration: BoxDecoration(
                          color: i == best ? bestColor : color,
                          borderRadius: BorderRadius.circular(AppRadius.r10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    style: text.tag.copyWith(
                      color: i == best ? colors.ink : colors.muted,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
