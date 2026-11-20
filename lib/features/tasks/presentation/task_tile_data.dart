import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/dates/sections.dart';
import 'package:ctrltask/core/widgets/task_content.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:ctrltask/features/tasks/domain/search_text.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/l10n/app_localizations.dart';
import 'package:ctrltask/l10n/date_text.dart';

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
  bool showDay = false,
  bool overdueAsDay = false,
  String? highlight,
  bool forSearch = false,
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
    titleMatches: highlight == null
        ? const []
        : matchRanges(task.title, highlight),
    // S27 lists tasks from many days, so it names the day. S24 reads
    // "Done · 2 Nov" for a done task.
    timeLabel: forSearch && task.status == TaskStatus.done
        ? l10n.doneOn(
            labels.dayMonth((task.completedAt ?? task.updatedAt).toLocal()),
          )
        : (showDay || forSearch) && due != null
        ? l10n.dayLabel(labels, due, today: now, minute: minute)
        : (minute == null ? null : labels.time(minute)),
    untimedLabel: untimedLabel,
    overdueLabel: !overdue
        ? null
        // Under S19's red Overdue header the day alone says it: "Yesterday".
        : overdueAsDay && !dueToday
        ? l10n.dayLabel(labels, due!, today: now)
        // S24: "Overdue · Mon, 16 Nov".
        : forSearch && !dueToday
        ? l10n.overdueOn(labels.date(due!))
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
