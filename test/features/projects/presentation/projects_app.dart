import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/complete_toast.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_timer.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/domain/project_repository.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:ctrltask/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/empty_repositories.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/live.dart';

/// For mocktail's `any()` on the fakes' arguments; call in `setUpAll`.
void registerProjectFallbacks() {
  registerFallbackValue(const TaskDraft(title: ''));
  registerFallbackValue(testProject(0, ''));
  registerFallbackValue(ProjectColorKey.grey);
  registerFallbackValue(ProjectIconKey.globe);
  registerFallbackValue((
    kind: FocusKind.focus,
    plannedSec: 0,
    startedAt: DateTime.utc(2026),
    endedAt: DateTime.utc(2026),
    elapsedSec: 0,
    taskId: null,
    completed: false,
  ));
  registerFallbackValue((
    before: TaskDetails(task: testTask(0, '')),
    nextId: null,
  ));
}

/// Tue 17 Nov 2026, 9:41 AM.
final testNow = DateTime(2026, 11, 17, 9, 41);

Project testProject(
  int id,
  String name, {
  ProjectColorKey color = ProjectColorKey.blue,
  ProjectIconKey icon = ProjectIconKey.globe,
  DateTime? deadline,
  String? description,
  DateTime? archivedAt,
}) => Project(
  id: id,
  name: name,
  colorKey: color,
  iconKey: icon,
  createdAt: DateTime.utc(2026),
  sortOrder: id,
  deadline: deadline,
  description: description,
  archivedAt: archivedAt,
);

Task testTask(
  int id,
  String title, {
  int? projectId,
  bool done = false,
  DateTime? dueDate,
}) => Task(
  id: id,
  title: title,
  priority: TaskPriority.medium,
  status: done ? TaskStatus.done : TaskStatus.open,
  boardColumn: done ? BoardColumn.done : BoardColumn.todo,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  sortOrder: id,
  projectId: projectId,
  dueDate: dueDate,
  completedAt: done ? DateTime.utc(2026, 11, 1, id) : null,
);

/// The real app and router over in-memory fakes that behave like the
/// database: every change streams to the screens watching it.
class ProjectsApp {
  new() {
    when(() => tasks.add(any())).thenAnswer((i) async {
      final draft = i.positionalArguments.single as TaskDraft;
      final task = testTask(
        900 + taskList.value.length,
        draft.title,
        projectId: draft.projectId,
      );
      taskList.value = [...taskList.value, task];
      return task;
    });
    when(() => tasks.complete(any())).thenAnswer((i) async {
      final id = i.positionalArguments.single as int;
      final before = taskList.value.firstWhere((t) => t.id == id);
      _replaceTask(
        before.copyWith(
          status: TaskStatus.done,
          boardColumn: BoardColumn.done,
          completedAt: testNow.toUtc(),
        ),
      );
      return (before: TaskDetails(task: before), nextId: null);
    });
    when(() => tasks.undoComplete(any())).thenAnswer((i) async {
      _replaceTask((i.positionalArguments.single as Completion).before.task);
    });

    when(
      () => projects.add(
        name: any(named: 'name'),
        colorKey: any(named: 'colorKey'),
        iconKey: any(named: 'iconKey'),
        description: any(named: 'description'),
        deadline: any(named: 'deadline'),
      ),
    ).thenAnswer((i) async {
      final name = (i.namedArguments[#name] as String).trim();
      _checkName(name, except: null);
      final project = testProject(
        50 + active.value.length,
        name,
        color: i.namedArguments[#colorKey] as ProjectColorKey,
        icon: i.namedArguments[#iconKey] as ProjectIconKey,
        description: i.namedArguments[#description] as String?,
        deadline: i.namedArguments[#deadline] as DateTime?,
      );
      active.value = [...active.value, project];
      return project;
    });
    when(() => projects.update(any())).thenAnswer((i) async {
      final project = i.positionalArguments.single as Project;
      _checkName(project.name, except: project.id);
      active.value = [
        for (final p in active.value)
          if (p.id == project.id) project else p,
      ];
    });
    when(() => projects.archive(any())).thenAnswer((i) async {
      final id = i.positionalArguments.single as int;
      final project = active.value.firstWhere((p) => p.id == id);
      active.value = [...active.value]..remove(project);
      archived.value = [
        ...archived.value,
        project.copyWith(archivedAt: testNow.toUtc()),
      ];
    });
    when(() => projects.restore(any())).thenAnswer((i) async {
      final id = i.positionalArguments.single as int;
      final project = archived.value.firstWhere((p) => p.id == id);
      _checkName(project.name, except: id);
      archived.value = [...archived.value]..remove(project);
      active.value = [...active.value, project.copyWith(archivedAt: null)];
    });
    when(() => projects.delete(any(), deleteTasks: any(named: 'deleteTasks')))
        .thenAnswer((i) async {
          final id = i.positionalArguments.single as int;
          active.value = [
            for (final p in active.value)
              if (p.id != id) p,
          ];
          taskList.value = [
            for (final t in taskList.value)
              if (t.projectId != id)
                t
              else if (i.namedArguments[#deleteTasks] != true)
                t.copyWith(projectId: null),
          ];
        });
  }

  final tasks = EmptyTasks();
  final projects = EmptyProjects();
  final focus = EmptyFocus();
  final active = Live<List<Project>>(const []);
  final archived = Live<List<Project>>(const []);
  final taskList = Live<List<Task>>(const []);
  final counts = Live<Map<int, int>>(const {});
  final focused = Live<int>(0);
  final sessions = Live<List<FocusSession>>(const []);
  final timers = MemoryFocusTimers();

  /// The app's clock; tests move it on.
  DateTime now = testNow;
  late ProviderContainer container;

  GoRouter get router => container.read(appRouterProvider);

  void _stubWatches() {
    when(projects.watchActive).thenAnswer((_) => active.stream);
    when(projects.watchArchived).thenAnswer((_) => archived.stream);
    when(tasks.watchTaskCounts).thenAnswer((_) => counts.stream);
    when(() => tasks.watchByProject(any())).thenAnswer(
      (i) => taskList.stream.map(
        (all) => [
          for (final t in all)
            if (t.projectId == i.positionalArguments.single) t,
        ],
      ),
    );
    when(() => tasks.watchAll(includeDone: any(named: 'includeDone')))
        .thenAnswer(
          (i) => taskList.stream.map(
            (all) => [
              for (final t in all)
                if (i.namedArguments[#includeDone] == true ||
                    t.status == TaskStatus.open)
                  t,
            ],
          ),
        );
    when(() => focus.watchFocusedSeconds(any()))
        .thenAnswer((_) => focused.stream);
    when(() => focus.watchStartedBetween(any(), any()))
        .thenAnswer((_) => sessions.stream);
    when(() => focus.add(any())).thenAnswer((i) async {
      final s = i.positionalArguments.single as EndedSession;
      sessions.value = [
        ...sessions.value,
        FocusSession(
          id: sessions.value.length + 1,
          kind: s.kind,
          plannedSec: s.plannedSec,
          startedAt: s.startedAt,
          endedAt: s.endedAt,
          elapsedSec: s.elapsedSec,
          taskId: s.taskId,
          completed: s.completed,
        ),
      ];
    });
  }

  void _replaceTask(Task task) => taskList.value = [
    for (final t in taskList.value)
      if (t.id == task.id) task else t,
  ];

  void _checkName(String name, {required int? except}) {
    final taken = active.value.any(
      (p) => p.id != except && p.name.toLowerCase() == name.toLowerCase(),
    );
    if (taken) throw DuplicateProjectNameException(name);
  }

  /// Opens the app on Home, then [location] on top so Back has somewhere
  /// to go. [brightness] and [textScale] set the platform's.
  Future<void> pump(
    WidgetTester tester, {
    String? location,
    String? go,
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = const Size(390, 1400)
      ..devicePixelRatio = 1;
    tester.platformDispatcher
      ..platformBrightnessTestValue = brightness
      ..textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    addTearDown(hideCompleteToast);
    container = ProviderContainer(
      overrides: [
        preferencesRepositoryProvider.overrideWithValue(
          FakePreferencesRepository(
            const Preferences(onboardingComplete: true),
          ),
        ),
        ...emptyRepositories(
          tasks: tasks,
          projectRepo: projects,
          focusRepo: focus,
          timers: timers,
        ),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    // emptyRepositories stubs fixed lists; these live ones win.
    _stubWatches();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    await tester.pumpAndSettle();
    if (go != null) {
      container.read(appRouterProvider).go(go);
      await tester.pumpAndSettle();
    }
    if (location != null) {
      container.read(appRouterProvider).push(location).ignore();
      await tester.pumpAndSettle();
    }
  }
}
