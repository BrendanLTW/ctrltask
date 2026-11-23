import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/theme/priority_colors.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/priority_tag.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/settings/presentation/preferences/choice_screen.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> _save(WidgetRef ref, Preferences Function(Preferences) change) =>
    ref.read(preferencesRepositoryProvider).update(change);

/// S37 Week starts on (PRD §5.10).
class WeekStartScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected =
        ref.watch(preferencesProvider).value?.weekStart ?? WeekStart.mon;
    return ChoiceScreen<WeekStart>(
      title: l10n.weekStartTitle,
      selected: selected,
      onChanged: (v) => _save(ref, (p) => p.copyWith(weekStart: v)),
      note: l10n.weekStartNote,
      choices: [
        for (final (day, detail) in [
          (WeekStart.mon, l10n.weekStartMonDetail),
          (WeekStart.sun, l10n.weekStartSunDetail),
          (WeekStart.sat, null),
        ])
          (
            value: day,
            title: l10n.weekStartName(day.name),
            detail: detail,
            leading: null,
          ),
      ],
    );
  }
}

/// S38 Default priority (PRD §5.10): each with its flag and what it looks
/// like.
class DefaultPriorityScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = context.projectColors;
    final selected =
        ref.watch(preferencesProvider).value?.defaultPriority ??
        TaskPriority.medium;
    return ChoiceScreen<TaskPriority>(
      title: l10n.defaultPriorityTitle,
      selected: selected,
      onChanged: (v) => _save(ref, (p) => p.copyWith(defaultPriority: v)),
      note: l10n.defaultPriorityNote,
      choices: [
        for (final (priority, detail) in [
          (TaskPriority.urgent, l10n.priorityUrgentDetail),
          (TaskPriority.high, l10n.priorityHighDetail),
          (TaskPriority.medium, l10n.priorityMediumDetail),
          (TaskPriority.low, l10n.priorityLowDetail),
        ])
          (
            value: priority,
            title: priorityLabel(context, priority),
            detail: detail,
            leading: AppIconView(
              AppIcon.flagFilled,
              size: 20,
              color: priority == TaskPriority.low
                  ? palette.of(ProjectColorKey.grey).solid
                  : context.priorityRing(priority),
            ),
          ),
      ],
    );
  }
}
