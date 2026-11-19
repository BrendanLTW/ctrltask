import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:flutter/material.dart';

/// A small stat (S07, S34, DESIGN §7): a tinted icon, a label, and a value
/// with a smaller unit ("12 days").
class StatTile extends StatelessWidget {
  const new({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.semanticLabel,
    this.unit,
    super.key,
  });

  final AppIcon icon;
  final ProjectColorKey color;

  /// Uppercase in the ARB copy: "STREAK".
  final String label;
  final String value;
  final String? unit;

  /// The whole stat in words: "Streak, 12 days".
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconTile(icon: icon, color: color, size: IconTileSize.small),
            const SizedBox(height: 12),
            Text(label, style: text.labelSm.copyWith(color: colors.muted)),
            const SizedBox(height: 2),
            Text.rich(
              TextSpan(
                text: value,
                style: text.statValue.copyWith(color: colors.ink),
                children: [
                  if (unit case final unit?)
                    TextSpan(
                      text: unit,
                      style: text.tag.copyWith(color: colors.muted),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
