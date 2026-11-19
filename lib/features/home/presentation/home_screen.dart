import 'dart:async';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/widgets/alert_banner.dart';
import 'package:ctrltask/core/widgets/app_shell.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/progress_hero.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/core/widgets/task_card.dart';
import 'package:ctrltask/core/widgets/task_row.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/home/presentation/home_all_done.dart';
import 'package:ctrltask/features/home/presentation/home_first_run.dart';
import 'package:ctrltask/features/home/presentation/home_header.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/home/presentation/home_stats.dart';
import 'package:ctrltask/features/home/presentation/upcoming_deadlines.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_calculations.dart';
import 'package:ctrltask/features/tasks/presentation/quick_add_sheet.dart';
import 'package:ctrltask/features/tasks/presentation/task_completion.dart';
import 'package:ctrltask/features/tasks/presentation/task_tile_data.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// S07 Home · Today (PRD §5.2): progress, stats, what's overdue, what's
/// due today and what's coming, all live. With no tasks at all it's S08's
/// blank page; once every task due today is done, S09's celebration.
class HomeScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final labels = DateLabels(locale);
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final todayList = ref.watch(todayTasksProvider).value ?? const <Task>[];
    final open = ref.watch(openTasksProvider).value ?? const <Task>[];
    final done = ref.watch(doneTasksProvider).value ?? const <Task>[];
    final sessions =
        ref.watch(focusTodayProvider).value ?? const <FocusSession>[];
    final projects = {
      for (final p
          in ref.watch(activeProjectsProvider).value ?? const <Project>[])
        p.id: p,
    };
    final subtasks = ref.watch(subtaskProgressProvider).value ?? const {};

    final progress = todayProgress(todayList);
    final left = progress.total - progress.done;
    final next = nextTask(todayList);
    final overdue = overdueTasks(open, now);
    final focused = Duration(
      seconds: sessions
          .where((s) => s.kind == FocusKind.focus && s.counts)
          .fold(0, (sum, s) => sum + s.elapsedSec),
    );
    final deadlines = upcomingDeadlines(open, projects.values, today);
    final firstRun = open.isEmpty && done.isEmpty && todayList.isEmpty;
    final allDone = progress.total > 0 && progress.done == progress.total;
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final tomorrowList = orderToday(open.where((t) => t.dueDate == tomorrow));

    void openTask(Task task) => context.push(Routes.task('${task.id}'));
    // shortcut: these open the Tasks tab until S19's overdue filter (2.11)
    // and the calendar (3.3) exist.
    void openTasksTab() => context.go(Routes.tasks);

    void addTask(String? title) =>
        unawaited(showQuickAdd(context, title: title));

    String subline() {
      if (progress.total == 0) return l10n.heroEmpty;
      if (next == null) return l10n.heroAllClear;
      final title = next.dueMinute == null
          ? next.title
          : l10n.dayWithTime(next.title, labels.time(next.dueMinute!));
      return l10n.heroLeftNext(left, title);
    }

    String overdueDetail(Task task) {
      final due = task.dueDate!;
      return switch (DateLabels.relativeDay(due, today)) {
        RelativeDay.today => l10n.wasDueAt(labels.time(task.dueMinute!)),
        RelativeDay.yesterday => l10n.wasDueYesterday,
        _ => l10n.wasDueOn(labels.date(due)),
      };
    }

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppShell.contentBottomPadding),
          children: [
            HomeHeader(
              date: labels.dateLong(today),
              greeting: firstRun
                  ? (prefs.userName.isEmpty
                        ? l10n.greetingWelcome
                        : l10n.greetingNamed(
                            l10n.greetingWelcome,
                            prefs.userName,
                          ))
                  : greeting(l10n, now, prefs.userName),
              name: prefs.userName,
              showSearch: !firstRun,
              onSearch: () => context.push(Routes.search),
              onAvatar: () => context.push(Routes.settings),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenX,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Only S07's hero opens Tasks; S08's and S09's have no arrow.
                  ProgressHero(
                    progress: progress,
                    subline: subline(),
                    onTap: firstRun || allDone ? null : openTasksTab,
                  ),
                  if (firstRun)
                    HomeFirstRun(
                      onAddTask: addTask,
                      onCreateProject: () =>
                          unawaited(context.push(Routes.newProject)),
                    )
                  else if (allDone) ...[
                    const SizedBox(height: 12),
                    DayDoneCard(
                      tasksDone: progress.done,
                      focused: focused,
                      streak: streak(done, today),
                      onPlanTomorrow: openTasksTab,
                    ),
                    if (tomorrowList.isNotEmpty) ...[
                      SectionHeader(
                        l10n.tomorrowSection(
                          DateFormat(
                            'EEE d',
                            locale,
                          ).format(tomorrow).toUpperCase(),
                        ),
                        linkLabel: l10n.allTasks,
                        onLink: openTasksTab,
                      ),
                      ListGroup(
                        children: [
                          for (final task in tomorrowList)
                            TaskRow(
                              data: taskTileData(
                                task,
                                l10n: l10n,
                                labels: labels,
                                now: now,
                                projects: projects,
                                subtasks: subtasks,
                                untimedLabel: l10n.anyTime,
                              ),
                              onToggle: (value) => unawaited(
                                setTaskDone(context, ref, task, done: value),
                              ),
                              onTap: () => openTask(task),
                              trailingTag: false,
                            ),
                        ],
                      ),
                    ],
                  ] else ...[
                    const SizedBox(height: 12),
                    HomeStats(
                      streak: streak(done, today),
                      focused: focused,
                      doneThisWeek: doneThisWeek(done, today, prefs.weekStart),
                    ),
                    if (overdue.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      AlertBanner(
                        title: l10n.overdueCount(overdue.length),
                        message: l10n.titleWithDetail(
                          overdue.first.title,
                          overdueDetail(overdue.first),
                        ),
                        onTap: overdue.length == 1
                            ? () => openTask(overdue.first)
                            : openTasksTab,
                      ),
                    ],
                    if (todayList.isNotEmpty) ...[
                      SectionHeader(
                        l10n.dueToday,
                        linkLabel: l10n.allTasks,
                        onLink: openTasksTab,
                      ),
                      for (final task in todayList) ...[
                        TaskCard(
                          data: taskTileData(
                            task,
                            l10n: l10n,
                            labels: labels,
                            now: now,
                            projects: projects,
                            subtasks: subtasks,
                          ),
                          onToggle: (value) => unawaited(
                            setTaskDone(context, ref, task, done: value),
                          ),
                          onTap: () => openTask(task),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                    if (deadlines.isNotEmpty) ...[
                      SectionHeader(
                        l10n.upcomingDeadlines,
                        linkLabel: l10n.calendar,
                        onLink: openTasksTab,
                      ),
                      UpcomingDeadlines(
                        items: deadlines,
                        projects: projects,
                        today: today,
                        labels: labels,
                        onTask: openTask,
                        onProject: (p) =>
                            context.push(Routes.project('${p.id}')),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
