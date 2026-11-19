import 'dart:async';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/dates/sections.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_shell.dart';
import 'package:ctrltask/core/widgets/empty_state.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/core/widgets/segmented_control.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/presentation/project_providers.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_list.dart';
import 'package:ctrltask/features/tasks/presentation/list/task_list_group.dart';
import 'package:ctrltask/features/tasks/presentation/quick_add_sheet.dart';
import 'package:ctrltask/features/tasks/presentation/tasks_providers.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum _View { list, calendar }

/// S19 Tasks (PRD §5.6): filter chips with live counts, tasks in date
/// sections, and swipe actions on every row.
class TasksScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  // shortcut: the Board segment (P2) comes with 5.1, the calendar with 3.3.
  _View _view = _View.list;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(
            top: 12,
            bottom: AppShell.contentBottomPadding,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.textX,
                0,
                AppSpacing.screenX,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        l10n.tabTasks,
                        style: context.text.pageTitle.copyWith(
                          color: colors.ink,
                        ),
                      ),
                    ),
                  ),
                  // shortcut: the filter button opens S23 from 3.4.
                  IconButton(
                    onPressed: () => unawaited(context.push(Routes.search)),
                    tooltip: l10n.search,
                    style: IconButton.styleFrom(
                      fixedSize: const Size(48, 48),
                      backgroundColor: colors.raised,
                      foregroundColor: colors.ink,
                    ),
                    icon: const AppIconView(AppIcon.search, size: 22),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenX,
              ),
              child: SegmentedControl<_View>(
                segments: [
                  (value: _View.list, label: l10n.listView, icon: AppIcon.list),
                  (
                    value: _View.calendar,
                    label: l10n.calendar,
                    icon: AppIcon.calendar,
                  ),
                ],
                selected: _view,
                onChanged: (view) => setState(() => _view = view),
              ),
            ),
            const SizedBox(height: 12),
            if (_view == _View.list)
              const _TaskList()
            else
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: EmptyState(
                  icon: AppIcon.calendar,
                  title: l10n.calendar,
                  body: l10n.calendarComingSoon,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TaskList extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart =
        ref.watch(preferencesProvider).value?.weekStart ?? WeekStart.mon;
    final all = ref.watch(allTasksProvider).value ?? const <Task>[];
    final projects = {
      for (final p
          in ref.watch(activeProjectsProvider).value ?? const <Project>[])
        p.id: p,
    };
    final subtasks = ref.watch(subtaskProgressProvider).value ?? const {};
    final filter = ref.watch(tasksFilterProvider);
    final counts = filterCounts(all, today: today);
    final shown = tasksFor(filter, all, today: today);

    TaskListGroup group(
      List<Task> tasks, {
      bool showDay = false,
      bool overdueAsDay = false,
    }) => TaskListGroup(
      tasks: tasks,
      now: now,
      labels: labels,
      projects: projects,
      subtasks: subtasks,
      showDay: showDay,
      overdueAsDay: overdueAsDay,
    );

    final List<Widget> body;
    if (!ref.watch(allTasksProvider).hasValue) {
      body = const [];
    } else if (shown.isEmpty) {
      body = [
        Padding(
          padding: const EdgeInsets.only(top: 64),
          child: _empty(context, filter),
        ),
      ];
    } else if (filter == TaskFilter.done) {
      body = [
        SectionHeader(l10n.sectionDone, detail: l10n.taskCount(shown.length)),
        group(shown, showDay: true),
      ];
    } else {
      final sections = sectionTasks(shown, today: today, weekStart: weekStart);
      // The design's hint sits on the first header after Today.
      final hintAt = sections.indexWhere(
        (s) => s.$1 != TaskSection.overdue && s.$1 != TaskSection.today,
      );
      body = [
        for (final (i, (section, tasks)) in sections.indexed) ...[
          SectionHeader(
            switch (section) {
              TaskSection.overdue => l10n.sectionOverdue,
              TaskSection.today => l10n.sectionToday(
                DateFormat('EEE d', locale).format(today).toUpperCase(),
              ),
              TaskSection.tomorrow => l10n.sectionTomorrow,
              TaskSection.thisWeek => l10n.sectionThisWeek,
              TaskSection.later => l10n.sectionLater,
              TaskSection.noDate => l10n.sectionNoDate,
            },
            alert: section == TaskSection.overdue,
            detail: switch (section) {
              TaskSection.overdue => l10n.taskCount(tasks.length),
              TaskSection.today => l10n.leftOfTotal(
                tasks.where((t) => t.status == TaskStatus.open).length,
                tasks.length,
              ),
              _ when i == hintAt => l10n.swipeHint,
              _ => null,
            },
          ),
          group(
            tasks,
            overdueAsDay: section == TaskSection.overdue,
            showDay:
                section == TaskSection.thisWeek || section == TaskSection.later,
          ),
        ],
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilterChips<TaskFilter>(
          chips: [
            for (final (f, label) in [
              (TaskFilter.all, l10n.filterAll),
              (TaskFilter.today, l10n.filterToday),
              (TaskFilter.upcoming, l10n.filterUpcoming),
              (TaskFilter.high, l10n.filterHigh),
              (TaskFilter.done, l10n.filterDone),
            ])
              (value: f, label: label, count: counts[f]),
          ],
          selected: filter,
          onChanged: (f) => ref.read(tasksFilterProvider.notifier).selected = f,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenX),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: body,
          ),
        ),
      ],
    );
  }

  Widget _empty(BuildContext context, TaskFilter filter) {
    final l10n = context.l10n;
    final (title, body) = switch (filter) {
      TaskFilter.all => (l10n.emptyAllTitle, l10n.emptyAllBody),
      TaskFilter.today => (l10n.emptyTodayTitle, l10n.emptyTodayBody),
      TaskFilter.upcoming => (l10n.emptyUpcomingTitle, l10n.emptyUpcomingBody),
      TaskFilter.high => (l10n.emptyHighTitle, l10n.emptyHighBody),
      TaskFilter.done => (l10n.emptyDoneTitle, l10n.emptyDoneBody),
    };
    return EmptyState(
      icon: filter == TaskFilter.done ? AppIcon.success : AppIcon.tasks,
      title: title,
      body: body,
      actionLabel: filter == TaskFilter.all ? l10n.addATask : null,
      actionIcon: AppIcon.add,
      onAction: filter == TaskFilter.all
          ? () => unawaited(showQuickAdd(context))
          : null,
    );
  }
}
