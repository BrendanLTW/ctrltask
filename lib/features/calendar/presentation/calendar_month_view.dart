import 'dart:async';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/month_calendar.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/features/calendar/domain/calendar_calculations.dart';
import 'package:ctrltask/features/calendar/presentation/calendar_providers.dart';
import 'package:ctrltask/features/calendar/presentation/calendar_span_chips.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/presentation/project_providers.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_calculations.dart';
import 'package:ctrltask/features/tasks/presentation/list/task_list_group.dart';
import 'package:ctrltask/l10n/date_text.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S21 Calendar · Month (PRD §5.6): the month with status dots, the
/// legend, and the picked day's agenda.
// shortcut: "Hold & drag to move" and drag to reschedule come with 5.5
// (v1.1).
class CalendarMonthView extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<CalendarMonthView> createState() => _CalendarMonthState();
}

class _CalendarMonthState extends ConsumerState<CalendarMonthView> {
  late DateTime _month = () {
    final day = ref.read(calendarDayProvider);
    return DateTime(day.year, day.month);
  }();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final day = ref.watch(calendarDayProvider);
    final weekStart =
        ref.watch(preferencesProvider).value?.weekStart ?? WeekStart.mon;
    final tasks = ref.watch(allTasksProvider).value ?? const <Task>[];
    final projects = {
      for (final p in ref.watch(activeProjectsProvider).value ?? <Project>[])
        p.id: p,
    };
    final subtasks = ref.watch(subtaskProgressProvider).value ?? const {};
    final statuses = dayStatuses(tasks, today: today);
    final agenda = orderToday(tasksDueOn(tasks, day));

    Widget legend(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: text.subline.copyWith(color: colors.muted)),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenX),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CalendarSpanChips(
                  selected: CalendarSpan.month,
                  onChanged: (span) {
                    if (span == CalendarSpan.month) return;
                    unawaited(context.push(Routes.calendar(span)));
                  },
                ),
                const SizedBox(height: 12),
                MonthCalendar(
                  month: _month,
                  today: today,
                  weekStart: weekStart,
                  selected: day,
                  onSelected: (picked) =>
                      ref.read(calendarDayProvider.notifier).day = picked,
                  onMonthChanged: (month) => setState(() => _month = month),
                  dotsFor: (d) => switch (statuses[d]) {
                    final s? => {
                      if (s.pending) CalendarDot.pending,
                      if (s.completed) CalendarDot.completed,
                      if (s.overdue) CalendarDot.overdue,
                    },
                    null => const {},
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.textX - AppSpacing.screenX,
            ),
            child: Wrap(
              spacing: 18,
              runSpacing: 6,
              children: [
                legend(colors.ink, l10n.legendPending),
                // The calendar's own dot colours.
                legend(
                  context.projectColors.of(ProjectColorKey.green).solid,
                  l10n.legendCompleted,
                ),
                legend(
                  context.projectColors.of(ProjectColorKey.red).solid,
                  l10n.legendOverdue,
                ),
              ],
            ),
          ),
          SectionHeader(
            switch (DateLabels.relativeDay(day, today)) {
              RelativeDay.other => labels.date(day),
              _ => l10n.agendaHeader(
                labels.date(day),
                l10n.dayLabel(labels, day, today: today),
              ),
            }.toUpperCase(),
            detail: agenda.isEmpty ? null : l10n.taskCount(agenda.length),
          ),
          if (agenda.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r28),
              ),
              child: Text(
                l10n.nothingDue,
                textAlign: TextAlign.center,
                style: text.body.copyWith(color: colors.muted),
              ),
            )
          else
            TaskListGroup(
              tasks: agenda,
              now: now,
              labels: labels,
              projects: projects,
              subtasks: subtasks,
            ),
        ],
      ),
    );
  }
}
