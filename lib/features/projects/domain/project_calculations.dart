import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';

/// Done out of all the project's tasks (PRD §8).
Progress projectProgress(Iterable<Task> tasks) => (
  done: tasks.where((t) => t.status == TaskStatus.done).length,
  total: tasks.length,
);

/// Calendar days from [today] to [deadline]; negative once it has passed.
int daysLeft(DateTime deadline, DateTime today) =>
    DateLabels.daysBetween(today, deadline);

/// The days-left tag turns red at 7 days or fewer (S26).
bool deadlineIsClose(int daysLeft) => daysLeft <= 7;
