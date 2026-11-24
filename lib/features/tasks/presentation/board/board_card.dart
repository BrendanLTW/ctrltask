import 'dart:async';
import 'dart:math' as math;

import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_shadows.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_progress_bar.dart';
import 'package:ctrltask/core/widgets/priority_tag.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';

/// A card on S20 (DESIGN §7): title, the priority tag for Urgent and High,
/// the due date, tags and a subtask bar. Long-press lifts it to drag to
/// another column; screen readers get a "Move to …" action per column.
class BoardCard extends StatelessWidget {
  const new({
    required this.task,
    required this.tags,
    required this.subtasks,
    required this.labels,
    required this.onMove,
    super.key,
  });

  final Task task;
  final List<String> tags;
  final Progress? subtasks;
  final DateLabels labels;
  final void Function(BoardColumn) onMove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final card = _Card(
      task: task,
      tags: tags,
      subtasks: subtasks,
      labels: labels,
    );
    return Semantics(
      customSemanticsActions: {
        for (final column in BoardColumn.values)
          if (column != task.boardColumn)
            CustomSemanticsAction(
              label: l10n.moveToColumn(l10n.columnName(column.name)),
            ): () =>
                onMove(column),
      },
      child: LongPressDraggable<Task>(
        data: task,
        feedback: SizedBox(
          width: 252,
          child: Transform.rotate(
            angle: -2.5 * math.pi / 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.r22),
                boxShadow: context.shadows.kanbanDrag,
              ),
              child: Material(type: MaterialType.transparency, child: card),
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.35, child: card),
        child: GestureDetector(
          onTap: () => unawaited(context.push(Routes.task('${task.id}'))),
          child: card,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const new({
    required this.task,
    required this.tags,
    required this.subtasks,
    required this.labels,
  });

  final Task task;
  final List<String> tags;
  final Progress? subtasks;
  final DateLabels labels;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final done = task.status == TaskStatus.done;
    final meta = text.subline.copyWith(color: colors.muted);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            task.title,
            style: text.rowTitle.copyWith(
              color: done ? colors.muted : colors.ink,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Medium and Low show as the ring on lists; cards keep to
              // what needs attention, as the design does.
              if (!done &&
                  (task.priority == TaskPriority.urgent ||
                      task.priority == TaskPriority.high))
                PriorityTag(task.priority),
              Text(switch (task.dueDate) {
                final d? => labels.date(d),
                null => l10n.noDate,
              }, style: meta),
              // One text, so a long tag wraps instead of overflowing.
              for (final tag in tags)
                Text.rich(
                  TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: AppIconView(
                            AppIcon.tag,
                            size: 16,
                            color: colors.muted,
                          ),
                        ),
                      ),
                      TextSpan(text: tag),
                    ],
                  ),
                  style: meta,
                ),
            ],
          ),
          if (subtasks case final s?) ...[
            const SizedBox(height: 12),
            AppProgressBar(
              value: s.fraction,
              thin: true,
              semanticLabel: l10n.subtaskSemantics(s.done, s.total),
            ),
          ],
        ],
      ),
    );
  }
}
