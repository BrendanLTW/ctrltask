import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_repository.g.dart';

/// What [TaskRepository.complete] changed, for Undo: the task as it was,
/// and the next occurrence it created, if any.
typedef Completion = ({TaskDetails before, int? nextId});

/// Tasks and what's attached to them (PRD §5.4, §6.1, §6.4, §8).
///
/// Watches leave out tasks in archived projects (PRD §5.7) and return tasks
/// by `sortOrder`; screens order them with the domain functions.
/// Writes throw [ArgumentError] when a field breaks a PRD §8 rule.
abstract interface class TaskRepository {
  /// Open tasks due on [today] and tasks completed on that local day.
  Stream<List<Task>> watchToday(DateTime today);

  /// Every task; done ones only when [includeDone].
  Stream<List<Task>> watchAll({bool includeDone = false});

  /// A project's tasks, or Inbox (no project) for null.
  Stream<List<Task>> watchByProject(int? projectId);

  /// Tasks due from [from] to [to], both local dates, inclusive.
  Stream<List<Task>> watchDueBetween(DateTime from, DateTime to);

  /// Tasks whose title, description, subtasks, tags or project contain
  /// [query], ignoring case. Empty for a blank query. A query starting
  /// with # matches only tags that start with the rest ("#des").
  Stream<List<Task>> search(String query);

  /// Ticked out of all subtasks, for every task that has any ("2/4").
  Stream<Map<int, Progress>> watchSubtaskProgress();

  /// How many tasks, open or done, each project has, archived ones
  /// included (S45). Projects without tasks are left out.
  Stream<Map<int, int>> watchTaskCounts();

  /// A task with its repeat rule, subtasks, tags and links; null once gone.
  Stream<TaskDetails?> watchDetails(int id);

  /// Creates the task, last in order. A repeating task without a date is
  /// due today (PRD §6.4).
  Future<Task> add(TaskDraft draft);

  /// Saves the edit form (S11): every task field, the repeat rule, and the
  /// subtasks, tags and links (new ones have id 0; missing ones are
  /// removed).
  Future<void> update(TaskDetails details);

  /// Marks the task done. A repeating task also gets its next occurrence,
  /// which takes over the repeat rule.
  Future<Completion> complete(int id);

  /// Undo for [complete]: puts the task back exactly and removes the
  /// occurrence it created.
  Future<void> undoComplete(Completion completion);

  /// Reopens a done task.
  Future<void> uncomplete(int id);

  /// Deletes the task with its subtasks, tags links and links, and returns
  /// it for [restore].
  Future<TaskDetails> delete(int id);

  /// Puts back a deleted task exactly, with its ids. Tags deleted since are
  /// left off.
  Future<void> restore(TaskDetails details);
}

/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.
@Riverpod(keepAlive: true)
TaskRepository taskRepository(Ref ref) =>
    throw UnimplementedError('Override taskRepositoryProvider');
