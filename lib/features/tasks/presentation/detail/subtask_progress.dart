import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_progress_bar.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/task_checkbox.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:ctrltask/features/tasks/domain/subtask.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S12's subtasks: the count and percentage, a thin bar, and rows that
/// tick straight away.
class SubtaskProgress extends StatelessWidget {
  const new({required this.subtasks, required this.onToggle, super.key});

  final List<Subtask> subtasks;
  final void Function(Subtask subtask, {required bool done}) onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final progress = (
      done: subtasks.where((s) => s.done).length,
      total: subtasks.length,
    );
    final style = text.rowTitle.copyWith(fontWeight: FontWeight.w500);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.textX - AppSpacing.screenX,
            AppSpacing.sectionTop,
            AppSpacing.textX - AppSpacing.screenX,
            10,
          ),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.subtasksHeader(progress.done, progress.total),
                    style: text.label.copyWith(color: colors.muted),
                  ),
                ),
              ),
              ExcludeSemantics(
                child: Text(
                  l10n.percent(progress.percent),
                  style: text.chip.copyWith(color: colors.muted),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
          child: AppProgressBar(
            value: progress.fraction,
            thin: true,
            semanticLabel: l10n.subtaskSemantics(progress.done, progress.total),
          ),
        ),
        ListGroup(
          children: [
            for (final s in subtasks)
              Padding(
                padding: const EdgeInsets.fromLTRB(7, 4, 18, 4),
                child: Row(
                  children: [
                    TaskCheckbox(
                      title: s.title,
                      priority: TaskPriority.low,
                      done: s.done,
                      size: 22,
                      onChanged: (v) => onToggle(s, done: v),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.title,
                        style: style.copyWith(
                          color: s.done ? colors.muted : colors.ink,
                          decoration: s.done
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: colors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
