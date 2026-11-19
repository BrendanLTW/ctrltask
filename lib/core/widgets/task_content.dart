import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/priority_tag.dart';
import 'package:ctrltask/core/widgets/project_dot.dart';
import 'package:ctrltask/core/widgets/task_checkbox.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// What a task card or row shows (PRD §6.1). Plain values, so screens
/// build the labels with `DateLabels` and `core/widgets` stays free of
/// feature code.
@immutable
class TaskTileData {
  const new({
    required this.title,
    required this.priority,
    required this.done,
    this.timeLabel,
    this.overdueLabel,
    this.projectName,
    this.projectColor,
    this.subtasks,
    this.repeats = false,
  });

  final String title;
  final TaskPriority priority;
  final bool done;

  /// "10:00 AM", shown with a clock.
  final String? timeLabel;

  /// "Overdue · Mon" or "Yesterday", in red in the time's place.
  final String? overdueLabel;
  final String? projectName;
  final ProjectColorKey? projectColor;

  /// Ticked out of all subtasks; null without subtasks.
  final Progress? subtasks;
  final bool repeats;

  /// Urgent and High get a tag, until the task is done.
  bool get showsTag =>
      !done &&
      (priority == TaskPriority.urgent || priority == TaskPriority.high);
}

/// The checkbox, title and meta line shared by `TaskCard` and `TaskRow`.
class TaskContent extends StatelessWidget {
  const new({
    required this.data,
    required this.onToggle,
    this.tagInMeta = true,
    this.trailing,
    super.key,
  });

  final TaskTileData data;
  final ValueChanged<bool> onToggle;

  /// Cards lead the meta line with the priority tag; rows put it in
  /// [trailing].
  final bool tagInMeta;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final meta = text.caption.copyWith(color: colors.muted);

    // Text with inline icons, so a long item wraps instead of overflowing.
    WidgetSpan icon(AppIcon icon) => WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.only(right: 5),
        child: AppIconView(icon, size: 14, color: colors.muted),
      ),
    );

    Widget iconText(AppIcon leading, String label, {String? semantics}) =>
        Semantics(
          label: semantics,
          excludeSemantics: semantics != null,
          child: Text.rich(
            TextSpan(
              children: [
                icon(leading),
                TextSpan(text: label),
              ],
            ),
            style: meta,
          ),
        );

    final items = <Widget>[
      if (tagInMeta && data.showsTag) PriorityTag(data.priority),
      if (data.overdueLabel case final overdue?)
        Text(overdue, style: meta.copyWith(color: colors.negative))
      else if (data.timeLabel case final time?)
        iconText(AppIcon.clock, time),
      if (data.projectName case final name?)
        Text.rich(
          TextSpan(
            children: [
              if (data.projectColor case final color?)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ProjectDot(color),
                  ),
                ),
              TextSpan(text: name),
            ],
          ),
          style: meta,
        ),
      if (data.subtasks case (:final done, :final total))
        iconText(
          AppIcon.subtask,
          l10n.subtaskCount(done, total),
          semantics: l10n.subtaskSemantics(done, total),
        ),
      if (data.repeats)
        Semantics(
          label: l10n.repeats,
          child: AppIconView(AppIcon.repeat, size: 14, color: colors.muted),
        ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskCheckbox(
          title: data.title,
          priority: data.priority,
          done: data.done,
          onChanged: onToggle,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            // Lines the title up with the 26 px circle in its 44 px target.
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: text.rowTitle.copyWith(
                    color: data.done ? colors.muted : colors.ink,
                    decoration: data.done ? TextDecoration.lineThrough : null,
                    decorationColor: colors.muted,
                  ),
                ),
                if (items.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: items,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (trailing case final trailing?)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 10),
            child: trailing,
          ),
      ],
    );
  }
}
