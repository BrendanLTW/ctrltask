import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/dates/sections.dart';
import 'package:ctrltask/core/widgets/task_content.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/l10n/app_localizations.dart';

/// A task card or row's labels (PRD §6.1). Overdue tasks read
/// "Overdue · Mon", or "Overdue · 10:00 AM" when due earlier today.
/// [untimedLabel] stands in for a missing time, as S09's "Any time".
TaskTileData taskTileData(
  Task task, {
  required AppLocalizations l10n,
  required DateLabels labels,
  required DateTime now,
  required Map<int, Project> projects,
  required Map<int, Progress> subtasks,
  String? untimedLabel,
}) {
  final project = projects[task.projectId];
  final due = task.dueDate;
  final minute = task.dueMinute;
  final overdue =
      task.status == TaskStatus.open &&
      isOverdue(dueDate: due, dueMinute: minute, now: now);
  final dueToday =
      due != null && DateLabels.relativeDay(due, now) == RelativeDay.today;
  return TaskTileData(
    title: task.title,
    priority: task.priority,
    done: task.status == TaskStatus.done,
    timeLabel: minute == null ? null : labels.time(minute),
    untimedLabel: untimedLabel,
    overdueLabel: !overdue
        ? null
        : l10n.overdueOn(
            dueToday && minute != null
                ? labels.time(minute)
                : labels.weekday(due!),
          ),
    projectName: project?.name,
    projectColor: project?.colorKey,
    subtasks: subtasks[task.id],
    repeats: task.repeatRuleId != null,
  );
}
