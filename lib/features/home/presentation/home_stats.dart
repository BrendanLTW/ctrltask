import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/large_text.dart';
import 'package:ctrltask/core/widgets/stat_tile.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/l10n/date_text.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Home's three stat tiles (S07): streak, focus today and done this week.
class HomeStats extends StatelessWidget {
  const new({
    required this.streak,
    required this.focused,
    required this.doneThisWeek,
    super.key,
  });

  final int streak;
  final Duration focused;
  final int doneThisWeek;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (focusValue, focusUnit) = l10n.durationParts(focused);
    return PairOrStack(
      gap: 10,
      children: [
        StatTile(
          icon: AppIcon.flame,
          color: ProjectColorKey.orange,
          label: l10n.statStreak,
          value: '$streak',
          unit: l10n.unitDays(streak),
          semanticLabel: l10n.streakSemantics(streak),
        ),
        StatTile(
          icon: AppIcon.timer,
          color: ProjectColorKey.purple,
          label: l10n.statFocused,
          value: focusValue,
          unit: focusUnit,
          semanticLabel: l10n.focusedSemantics(l10n.durationLabel(focused)),
        ),
        StatTile(
          icon: AppIcon.check,
          color: ProjectColorKey.green,
          label: l10n.statThisWeek,
          value: '$doneThisWeek',
          unit: l10n.unitDone,
          semanticLabel: l10n.thisWeekSemantics(doneThisWeek),
        ),
      ],
    );
  }
}
