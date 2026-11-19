import 'package:ctrltask/features/focus/domain/focus_session_repository.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'project_providers.g.dart';

@riverpod
Stream<List<Project>> archivedProjects(Ref ref) =>
    ref.watch(projectRepositoryProvider).watchArchived();

/// Open and done tasks outside archived projects: S26's progress.
@riverpod
Stream<List<Task>> allTasks(Ref ref) =>
    ref.watch(taskRepositoryProvider).watchAll(includeDone: true);

/// Tasks per project, archived ones included: S45's counts.
@riverpod
Stream<Map<int, int>> projectTaskCounts(Ref ref) =>
    ref.watch(taskRepositoryProvider).watchTaskCounts();

@riverpod
Stream<List<Task>> projectTasks(Ref ref, int projectId) =>
    ref.watch(taskRepositoryProvider).watchByProject(projectId);

@riverpod
Stream<int> projectFocusedSeconds(Ref ref, int projectId) =>
    ref.watch(focusSessionRepositoryProvider).watchFocusedSeconds(projectId);
