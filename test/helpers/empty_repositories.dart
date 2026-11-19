import 'package:ctrltask/features/focus/domain/focus_session_repository.dart';
import 'package:ctrltask/features/projects/domain/project_repository.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:mocktail/mocktail.dart';

class EmptyTasks extends Mock implements TaskRepository;

class _Projects extends Mock implements ProjectRepository;

class _Focus extends Mock implements FocusSessionRepository;

/// Repositories with nothing in them, for tests that only need screens to
/// open. Pass [tasks] to stub more on the task repository.
List<Override> emptyRepositories({EmptyTasks? tasks}) {
  final t = tasks ?? EmptyTasks();
  when(() => t.watchToday(any())).thenAnswer((_) => Stream.value(const []));
  when(() => t.watchAll(includeDone: any(named: 'includeDone')))
      .thenAnswer((_) => Stream.value(const []));
  when(t.watchSubtaskProgress).thenAnswer((_) => Stream.value(const {}));
  final projects = _Projects();
  when(projects.watchActive).thenAnswer((_) => Stream.value(const []));
  final focus = _Focus();
  when(() => focus.watchStartedBetween(any(), any()))
      .thenAnswer((_) => Stream.value(const []));
  return [
    taskRepositoryProvider.overrideWithValue(t),
    projectRepositoryProvider.overrideWithValue(projects),
    focusSessionRepositoryProvider.overrideWithValue(focus),
  ];
}
