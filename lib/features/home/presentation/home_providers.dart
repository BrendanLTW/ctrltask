import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_session_repository.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_repository.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_calculations.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

/// Today's local date, from the injected clock.
// shortcut: read when Home builds, so it doesn't roll over at midnight while
// the app stays open; 3.7 refreshes on resume.
DateTime homeToday(Ref ref) {
  final now = ref.read(clockProvider)();
  return DateTime(now.year, now.month, now.day);
}

/// Today's list in display order (PRD §8).
@riverpod
Stream<List<Task>> todayTasks(Ref ref) => ref
    .watch(taskRepositoryProvider)
    .watchToday(homeToday(ref))
    .map(orderToday);

/// Every open task, for the overdue banner and upcoming deadlines.
@riverpod
Stream<List<Task>> openTasks(Ref ref) =>
    ref.watch(taskRepositoryProvider).watchAll();

/// Every done task, for the streak and done this week.
@riverpod
Stream<List<Task>> doneTasks(Ref ref) => ref
    .watch(taskRepositoryProvider)
    .watchAll(includeDone: true)
    .map(
      (all) => [
        for (final t in all)
          if (t.status == TaskStatus.done) t,
      ],
    );

@riverpod
Stream<List<Project>> activeProjects(Ref ref) =>
    ref.watch(projectRepositoryProvider).watchActive();

@riverpod
Stream<Map<int, Progress>> subtaskProgress(Ref ref) =>
    ref.watch(taskRepositoryProvider).watchSubtaskProgress();

/// Today's focus sessions.
@riverpod
Stream<List<FocusSession>> focusToday(Ref ref) {
  final today = homeToday(ref);
  return ref
      .watch(focusSessionRepositoryProvider)
      .watchStartedBetween(today, today);
}
