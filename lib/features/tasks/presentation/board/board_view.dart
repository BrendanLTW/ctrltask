import 'dart:async';

import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/project_dot.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/presentation/move_to_project_sheet.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:ctrltask/features/tasks/presentation/board/board_card.dart';
import 'package:ctrltask/features/tasks/presentation/board/kanban_column.dart';
import 'package:ctrltask/features/tasks/presentation/quick_add_sheet.dart';
import 'package:ctrltask/features/tasks/presentation/task_completion.dart';
import 'package:ctrltask/features/tasks/presentation/tasks_providers.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Moves [task] to [column] on S20. Into Done completes it through the one
/// completion path (toast and Undo, a repeat's next date); out of Done
/// reopens it in that column.
Future<void> moveTask(
  BuildContext context,
  WidgetRef ref,
  Task task,
  BoardColumn column,
) async {
  if (column == task.boardColumn) return;
  final repo = ref.read(taskRepositoryProvider);
  if (column == BoardColumn.done) {
    return await setTaskDone(context, ref, task, done: true);
  }
  if (task.status == TaskStatus.done) {
    return await repo.uncomplete(task.id, into: column);
  }
  await repo.moveToColumn(task.id, column);
}

/// S20 Board (PRD §5.3, v1.1): one project's tasks in To do, In progress
/// and Done, side by side.
class BoardView extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    final projects = ref.watch(activeProjectsProvider).value ?? const [];
    // The chosen project; at first the first active one, else the Inbox.
    final projectId = switch (ref.watch(boardProjectProvider)) {
      (:final projectId) => projectId,
      null => projects.firstOrNull?.id,
    };
    final project = projects.where((p) => p.id == projectId).firstOrNull;
    final tasks = ref.watch(boardTasksProvider(projectId)).value ?? const [];
    final tags = ref.watch(taskTagNamesProvider).value ?? const {};
    final subtasks = ref.watch(subtaskProgressProvider).value ?? const {};

    List<Widget> cardsIn(BoardColumn column) => [
      for (final task in [
        for (final t in tasks)
          if (t.boardColumn == column) t,
      ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
        BoardCard(
          key: ValueKey(task.id),
          task: task,
          tags: tags[task.id] ?? const [],
          subtasks: subtasks[task.id],
          labels: labels,
          onMove: (to) => unawaited(moveTask(context, ref, task, to)),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenX),
          child: Row(
            children: [
              _ProjectChip(project: project, projectId: projectId),
              const SizedBox(width: 8),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  l10n.groupedByStatus,
                  style: context.text.chip.copyWith(color: colors.muted),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, column) in BoardColumn.values.indexed) ...[
                if (i > 0) const SizedBox(width: 6),
                KanbanColumn(
                  column: column,
                  cards: cardsIn(column),
                  onDrop: (task) =>
                      unawaited(moveTask(context, ref, task, column)),
                  onAdd: column == BoardColumn.done
                      ? null
                      : () => unawaited(
                          showQuickAdd(
                            context,
                            projectId: projectId,
                            column: column,
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// "● Website redesign ⌄": opens S17 to pick another project or the Inbox.
class _ProjectChip extends ConsumerWidget {
  const new({required this.project, required this.projectId});

  final Project? project;
  final int? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AppChip(
      label: project?.name ?? l10n.inbox,
      leading: ProjectDot(project?.colorKey ?? ProjectColorKey.grey),
      // A picker opens below: the right chevron, turned.
      trailing: const RotatedBox(
        quarterTurns: 1,
        child: AppIconView(
          AppIcon.chevronRight,
          size: 16,
          stroke: AppIconStroke.chevron,
        ),
      ),
      onTap: () async {
        final pick = await showMoveToProject(context, current: projectId);
        if (pick != null) ref.read(boardProjectProvider.notifier).choice = pick;
      },
    );
  }
}
