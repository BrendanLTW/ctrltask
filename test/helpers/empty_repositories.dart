import 'package:ctrltask/features/focus/domain/focus_session_repository.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_repository.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:mocktail/mocktail.dart';

class EmptyTasks extends Mock implements TaskRepository;

class _Projects extends Mock implements ProjectRepository;

class _Focus extends Mock implements FocusSessionRepository;

/// Repositories with nothing in them, for tests that only need screens to
/// open. Pass [tasks] to stub more on the task repository, and [projects]
/// for active projects.
List<Override> emptyRepositories({
  EmptyTasks? tasks,
  List<Project> projects = const [],
}) {
  final t = tasks ?? EmptyTasks();
  when(() => t.watchToday(any())).thenAnswer((_) => Stream.value(const []));
  when(() => t.watchAll(includeDone: any(named: 'includeDone')))
      .thenAnswer((_) => Stream.value(const []));
  when(t.watchSubtaskProgress).thenAnswer((_) => Stream.value(const {}));
  final projectRepo = _Projects();
  when(projectRepo.watchActive).thenAnswer((_) => Stream.value(projects));
  final focus = _Focus();
  when(() => focus.watchStartedBetween(any(), any()))
      .thenAnswer((_) => Stream.value(const []));
  return [
    taskRepositoryProvider.overrideWithValue(t),
    projectRepositoryProvider.overrideWithValue(projectRepo),
    focusSessionRepositoryProvider.overrideWithValue(focus),
  ];
}
