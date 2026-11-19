import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A pill progress bar (DESIGN §7): 10 high, or 6 when [thin]. [value] is
/// clamped to 0–1.
class AppProgressBar extends StatelessWidget {
  const new({
    required this.value,
    required this.semanticLabel,
    this.color,
    this.trackColor,
    this.onHero = false,
    this.thin = false,
    super.key,
  });

  final double value;

  /// Read by screen readers, e.g. "5 of 8 tasks done".
  final String semanticLabel;

  /// The fill: `ink` by default, or a project's solid colour.
  final Color? color;

  /// The track: `raised` by default, or a project's tile colour.
  final Color? trackColor;

  /// The hero card's style: `heroTrack` track, `onHero` fill.
  final bool onHero;

  /// 6 high, as under S12's subtasks.
  final bool thin;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fill = color ?? (onHero ? colors.onHero : colors.ink);
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        height: thin ? 6 : 10,
        decoration: ShapeDecoration(
          color: trackColor ?? (onHero ? colors.heroTrack : colors.raised),
          shape: const StadiumBorder(),
        ),
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          widthFactor: value.isNaN ? 0 : value.clamp(0, 1),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: fill,
              shape: const StadiumBorder(),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
