import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// S34's power day: "Thursday is your power day — You finish 5.2 tasks on
/// average, mostly before noon."
class PowerDayCard extends StatelessWidget {
  const new({
    required this.weekday,
    required this.average,
    required this.beforeNoon,
    super.key,
  });

  /// "Thursday".
  final String weekday;
  final double average;
  final bool beforeNoon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r32),
      ),
      child: Row(
        children: [
          const IconTile(icon: AppIcon.zap, color: ProjectColorKey.yellow),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.powerDayTitle(weekday),
                  style: text.cardTitle.copyWith(color: colors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.powerDayBody(
                    NumberFormat('0.#', locale).format(average),
                    '$beforeNoon',
                  ),
                  style: text.subline.copyWith(color: colors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
