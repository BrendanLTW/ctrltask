import 'dart:async';
import 'dart:math' as math;

import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_shadows.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
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

/// Gives [task] a new due day and time: S14's Reschedule and S21's drag.
Future<void> setTaskDue(
  WidgetRef ref,
  Task task, {
  required DateTime date,
  required int? minute,
}) async {
  final repo = ref.read(taskRepositoryProvider);
  final details = await repo.watchDetails(task.id).first;
  if (details == null) return;
  await repo.update(
    details.copyWith(
      task: details.task.copyWith(dueDate: date, dueMinute: minute),
    ),
  );
}

/// One S19 section's rows: swipe right to complete, left for Reschedule
/// (S14) and Delete (S13). [draggable] rows also lift on a long press, to
/// drop on a day (S21).
class TaskListGroup extends ConsumerWidget {
  const new({
    required this.tasks,
    required this.now,
    required this.labels,
    required this.projects,
    required this.subtasks,
    this.showDay = false,
    this.overdueAsDay = false,
    this.draggable = false,
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

  final bool draggable;

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
    await setTaskDue(ref, task, date: choice.date, minute: choice.minute);
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
    Widget row(Task task, Widget child) => draggable
        ? LongPressDraggable<Task>(
            key: ValueKey(task.id),
            data: task,
            feedback: _DragFeedback(title: task.title),
            childWhenDragging: Opacity(opacity: 0.35, child: child),
            child: child,
          )
        : child;
    return ListGroup(
      children: [
        for (final task in tasks)
          row(
            task,
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
          ),
      ],
    );
  }
}

/// The lifted row: the title on a card, tilted like a board card (S20).
class _DragFeedback extends StatelessWidget {
  const new({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 300,
      child: Transform.rotate(
        angle: -2.5 * math.pi / 180,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r22),
              boxShadow: context.shadows.kanbanDrag,
            ),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.rowTitle.copyWith(color: colors.ink),
            ),
          ),
        ),
      ),
    );
  }
}
