import 'dart:async';

import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/app_dialog.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/swipe_actions.dart';
import 'package:ctrltask/core/widgets/task_row.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:ctrltask/features/tasks/presentation/detail/delete_task_dialog.dart';
import 'package:ctrltask/features/tasks/presentation/due_date_picker.dart';
import 'package:ctrltask/features/tasks/presentation/task_completion.dart';
import 'package:ctrltask/features/tasks/presentation/task_tile_data.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// One S19 section's rows: swipe right to complete, left for Reschedule
/// (S14) and Delete (S13).
class TaskListGroup extends ConsumerWidget {
  const new({
    required this.tasks,
    required this.now,
    required this.labels,
    required this.projects,
    required this.subtasks,
    this.showDay = false,
    this.overdueAsDay = false,
    super.key,
  });

  final List<Task> tasks;
  final DateTime now;
  final DateLabels labels;
  final Map<int, Project> projects;
  final Map<int, Progress> subtasks;

  /// Rows name their day (This week, Later, Done).
  final bool showDay;

  /// Overdue rows show the day in red ("Yesterday").
  final bool overdueAsDay;

  Future<void> _reschedule(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    final choice = await showDueDatePicker(
      context,
      date: task.dueDate,
      minute: task.dueMinute,
    );
    if (choice == null) return;
    final repo = ref.read(taskRepositoryProvider);
    final details = await repo.watchDetails(task.id).first;
    if (details == null) return;
    await repo.update(
      details.copyWith(
        task: details.task.copyWith(
          dueDate: choice.date,
          dueMinute: choice.minute,
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Task task) async {
    final choice = await confirmDeleteTask(
      context,
      title: task.title,
      subtaskCount: subtasks[task.id]?.total ?? 0,
      project: projects[task.projectId]?.name ?? context.l10n.inbox,
    );
    if (!context.mounted) return;
    switch (choice) {
      case DialogChoice.confirm:
        // shortcut: 3.7 also cancels the task's reminder here.
        await ref.read(taskRepositoryProvider).delete(task.id);
      case DialogChoice.secondary:
        await setTaskDone(context, ref, task, done: true);
      case DialogChoice.cancel:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ListGroup(
      children: [
        for (final task in tasks)
          SwipeActions(
            key: ValueKey(task.id),
            completeLabel: l10n.completeTask,
            onComplete: task.status == TaskStatus.open
                ? () => unawaited(setTaskDone(context, ref, task, done: true))
                : null,
            actions: [
              (
                label: l10n.reschedule,
                icon: AppIcon.calendar,
                color: ProjectColorKey.blue,
                onTap: () => unawaited(_reschedule(context, ref, task)),
              ),
              (
                label: l10n.delete,
                icon: AppIcon.trash,
                color: ProjectColorKey.red,
                onTap: () => unawaited(_delete(context, ref, task)),
              ),
            ],
            child: TaskRow(
              data: taskTileData(
                task,
                l10n: l10n,
                labels: labels,
                now: now,
                projects: projects,
                subtasks: subtasks,
                showDay: showDay,
                overdueAsDay: overdueAsDay,
              ),
              onToggle: (value) =>
                  unawaited(setTaskDone(context, ref, task, done: value)),
              onTap: () => unawaited(context.push(Routes.task('${task.id}'))),
            ),
          ),
      ],
    );
  }
}
