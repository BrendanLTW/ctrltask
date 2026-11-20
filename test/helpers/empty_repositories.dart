import 'dart:async';

import 'package:ctrltask/features/focus/domain/focus_session_repository.dart';
import 'package:ctrltask/features/focus/domain/focus_timer.dart';
import 'package:ctrltask/features/focus/domain/focus_timer_repository.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_repository.dart';
import 'package:ctrltask/features/tags/domain/tag_repository.dart';
import 'package:ctrltask/features/tasks/domain/recent_searches_repository.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:mocktail/mocktail.dart';

class EmptyTasks extends Mock implements TaskRepository {
  /// No task by default; a test's own `watchDetails` stub, added later,
  /// wins.
  new() {
    when(() => watchDetails(any())).thenAnswer((_) => Stream.value(null));
  }
}

class EmptyProjects extends Mock implements ProjectRepository;

class EmptyFocus extends Mock implements FocusSessionRepository;

class _Tags extends Mock implements TagRepository;

/// Recent searches kept in memory, live.
class MemoryRecentSearches implements RecentSearchesRepository {
  final _changes = StreamController<List<String>>.broadcast();
  List<String> value = [];

  @override
  Stream<List<String>> watch() async* {
    yield value;
    yield* _changes.stream;
  }

  @override
  Future<void> add(String query) async {
    final text = query.trim();
    if (text.isEmpty) return;
    value = [
      text,
      for (final q in value)
        if (q.toLowerCase() != text.toLowerCase()) q,
    ].take(RecentSearchesRepository.keep).toList();
    _changes.add(value);
  }

  @override
  Future<void> clear() async {
    value = [];
    _changes.add(value);
  }
}

/// A timer store that starts empty and keeps what's saved, live.
class MemoryFocusTimers implements FocusTimerRepository {
  final _saved = StreamController<FocusTimer?>.broadcast();
  FocusTimer? value;

  @override
  Stream<FocusTimer?> watch() async* {
    yield value;
    yield* _saved.stream;
  }

  @override
  Future<void> save(FocusTimer timer) async {
    value = timer;
    _saved.add(timer);
  }
}

/// Repositories with nothing in them, for tests that only need screens to
/// open. Pass [tasks] to stub more on the task repository, [projects] for
/// active projects and [archived] for archived ones. Pass [projectRepo] or
/// [focusRepo] to stub more on those; stubs added later win.
List<Override> emptyRepositories({
  EmptyTasks? tasks,
  EmptyProjects? projectRepo,
  EmptyFocus? focusRepo,
  MemoryFocusTimers? timers,
  MemoryRecentSearches? recent,
  List<Project> projects = const [],
  List<Project> archived = const [],
}) {
  final t = tasks ?? EmptyTasks();
  when(() => t.watchToday(any())).thenAnswer((_) => Stream.value(const []));
  when(() => t.watchAll(includeDone: any(named: 'includeDone')))
      .thenAnswer((_) => Stream.value(const []));
  when(t.watchSubtaskProgress).thenAnswer((_) => Stream.value(const {}));
  when(t.watchTaskCounts).thenAnswer((_) => Stream.value(const {}));
  when(() => t.watchByProject(any())).thenAnswer((_) => Stream.value(const []));
  final projectFake = projectRepo ?? EmptyProjects();
  when(projectFake.watchActive).thenAnswer((_) => Stream.value(projects));
  when(projectFake.watchArchived).thenAnswer((_) => Stream.value(archived));
  final focus = focusRepo ?? EmptyFocus();
  final tags = _Tags();
  when(tags.watch).thenAnswer((_) => Stream.value(const []));
  when(() => focus.watchStartedBetween(any(), any()))
      .thenAnswer((_) => Stream.value(const []));
  when(() => focus.watchFocusedSeconds(any()))
      .thenAnswer((_) => Stream.value(0));
  return [
    taskRepositoryProvider.overrideWithValue(t),
    projectRepositoryProvider.overrideWithValue(projectFake),
    focusSessionRepositoryProvider.overrideWithValue(focus),
    tagRepositoryProvider.overrideWithValue(tags),
    recentSearchesRepositoryProvider.overrideWithValue(
      recent ?? MemoryRecentSearches(),
    ),
    focusTimerRepositoryProvider.overrideWithValue(
      timers ?? MemoryFocusTimers(),
    ),
  ];
}
