import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/priority_tag.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_calculations.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// A task or project deadline after today.
typedef Deadline = ({DateTime date, Task? task, Project? project});

/// The next [count] open dated tasks or project deadlines after [today],
/// soonest first (PRD §5.2).
List<Deadline> upcomingDeadlines(
  Iterable<Task> openTasks,
  Iterable<Project> projects,
  DateTime today, {
  int count = 3,
}) {
  final items = <Deadline>[
    for (final t in openTasks)
      if (t.dueDate case final d? when d.isAfter(today))
        (date: d, task: t, project: null),
    for (final p in projects)
      if (p.deadline case final d? when d.isAfter(today))
        (date: d, task: null, project: p),
  ]..sort((a, b) => a.date.compareTo(b.date));
  return items.take(count).toList();
}

/// Home's Upcoming deadlines (S07): each row with its date and project, and
/// a priority tag or the days left.
class UpcomingDeadlines extends StatelessWidget {
  const new({
    required this.items,
    required this.projects,
    required this.today,
    required this.labels,
    required this.onTask,
    required this.onProject,
    super.key,
  });

  final List<Deadline> items;
  final Map<int, Project> projects;
  final DateTime today;
  final DateLabels labels;
  final ValueChanged<Task> onTask;
  final ValueChanged<Project> onProject;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListGroup(
      children: [
        for (final item in items)
          if (item.task case final task?)
            _row(
              title: task.title,
              detail: [
                labels.date(item.date),
                ?projects[task.projectId]?.name,
              ].join(' · '),
              tile: projects[task.projectId],
              trailing:
                  task.priority == TaskPriority.urgent ||
                      task.priority == TaskPriority.high
                  ? PriorityTag(task.priority)
                  : _days(context, item, close: false),
              onTap: () => onTask(task),
            )
          else if (item.project case final project?)
            _row(
              title: project.name,
              detail: '${labels.date(item.date)} · ${l10n.projectDeadline}',
              tile: project,
              trailing: _days(
                context,
                item,
                close: deadlineIsClose(daysLeft(item.date, today)),
              ),
              onTap: () => onProject(project),
            ),
      ],
    );
  }

  Widget _row({
    required String title,
    required String detail,
    required Project? tile,
    required Widget trailing,
    required VoidCallback onTap,
  }) => ListGroupRow(
    title: title,
    subtitle: detail,
    leading: tile == null
        ? null
        : IconTile.forProject(
            tile.iconKey,
            color: tile.colorKey,
            size: IconTileSize.medium,
          ),
    trailing: trailing,
    onTap: onTap,
  );

  Widget _days(BuildContext context, Deadline item, {required bool close}) {
    final colors = context.colors;
    return Text(
      context.l10n.dayCount(daysLeft(item.date, today)),
      style: context.text.chip.copyWith(
        color: close ? colors.negative : colors.muted,
      ),
    );
  }
}
