import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// A − value + stepper (S31, DESIGN §7): two 44 px `fillSoft` keys around
/// the value. A null callback disables that key at its limit. Screen
/// readers can adjust it.
class AppStepper extends StatelessWidget {
  const new({
    required this.value,
    required this.semanticLabel,
    required this.onDecrement,
    required this.onIncrement,
    this.decreasedValue,
    this.increasedValue,
    super.key,
  }) : assert(
         (onDecrement == null) == (decreasedValue == null) &&
             (onIncrement == null) == (increasedValue == null),
         'each working key needs the value it leads to',
       );

  /// "25 min".
  final String value;

  /// "Focus length".
  final String semanticLabel;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  /// What screen readers announce after each step: "20 min", "30 min".
  final String? decreasedValue;
  final String? increasedValue;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;

    Widget key(AppIcon icon, String tooltip, VoidCallback? onTap) => Tooltip(
      message: tooltip,
      excludeFromSemantics: true,
      child: Material(
        color: colors.fillSoft,
        borderRadius: BorderRadius.circular(AppRadius.r14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          highlightColor: colors.raised,
          splashFactory: NoSplash.splashFactory,
          child: SizedBox.square(
            dimension: 44,
            child: AppIconView(
              icon,
              size: 20,
              color: onTap == null ? colors.disabled : colors.ink,
              stroke: AppIconStroke.chevron,
            ),
          ),
        ),
      ),
    );

    return Semantics(
      label: semanticLabel,
      value: value,
      decreasedValue: decreasedValue,
      increasedValue: increasedValue,
      onIncrease: onIncrement,
      onDecrease: onDecrement,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          key(AppIcon.minus, l10n.decrease, onDecrement),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 64),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: text.rowTitle.copyWith(
                color: colors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          key(AppIcon.add, l10n.increase, onIncrement),
        ],
      ),
    );
  }
}
