import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/links/link_opener.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/complete_toast.dart';
import 'package:ctrltask/core/widgets/task_checkbox.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tags/domain/tag.dart';
import 'package:ctrltask/features/tasks/domain/subtask.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:ctrltask/features/tasks/domain/task_link.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:ctrltask/features/tasks/presentation/task_detail_screen.dart';
import 'package:ctrltask/features/tasks/presentation/task_form_screen.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:ctrltask/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/empty_repositories.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/live.dart';

class _Opener extends Mock implements LinkOpener;

void main() {
  late EmptyTasks tasks;
  late _Opener opener;
  late Live<TaskDetails?> live;
  late FakePreferencesRepository prefs;
  late ProviderContainer container;

  final website = Project(
    id: 1,
    name: 'Website redesign',
    colorKey: ProjectColorKey.blue,
    iconKey: ProjectIconKey.globe,
    createdAt: DateTime.utc(2026),
    sortOrder: 0,
  );
  final task = Task(
    id: 7,
    title: 'Review homepage wireframes',
    description: 'Check the hero.',
    priority: TaskPriority.high,
    status: TaskStatus.open,
    boardColumn: BoardColumn.todo,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    sortOrder: 0,
    dueDate: DateTime(2026, 11, 19),
    dueMinute: 900,
    projectId: 1,
  );
  final full = TaskDetails(
    task: task,
    tags: const [
      Tag(id: 1, name: 'design'),
      Tag(id: 2, name: 'review'),
    ],
    subtasks: [
      for (final (i, t) in ['Hero', 'Pricing', 'Nav', 'Footer'].indexed)
        Subtask(id: i + 1, taskId: 7, title: t, sortOrder: i, done: i < 2),
    ],
    links: const [
      TaskLink(id: 1, taskId: 7, title: 'Wireframes v3', url: 'https://f.co/w'),
    ],
  );

  setUpAll(() {
    registerFallbackValue(full);
    registerFallbackValue(Uri());
    registerFallbackValue((before: full, nextId: null));
  });

  setUp(() {
    live = Live<TaskDetails?>(full);
    prefs = FakePreferencesRepository(
      const Preferences(onboardingComplete: true),
    );
    tasks = EmptyTasks();
    opener = _Opener();
    when(() => opener.open(any())).thenAnswer((_) async => true);
    when(() => tasks.watchDetails(7)).thenAnswer((_) => live.stream);
    when(() => tasks.update(any())).thenAnswer((i) async {
      live.value = i.positionalArguments.single as TaskDetails;
    });
    when(() => tasks.complete(7)).thenAnswer((_) async {
      final before = live.value!;
      live.value = before.copyWith(
        task: before.task.copyWith(
          status: TaskStatus.done,
          boardColumn: BoardColumn.done,
        ),
      );
      return (before: before, nextId: null);
    });
    when(() => tasks.undoComplete(any())).thenAnswer((i) async {
      live.value = (i.positionalArguments.single as Completion).before;
    });
    when(() => tasks.delete(7)).thenAnswer((_) async {
      final before = live.value!;
      live.value = null;
      return before;
    });
  });

  tearDown(hideCompleteToast);

  /// The app over Home, with the task pushed on top so Back has somewhere
  /// to go.
  Future<void> pumpDetail(
    WidgetTester tester, {
    ThemeData? theme,
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = const Size(390, 1400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(
      overrides: [
        preferencesRepositoryProvider.overrideWithValue(prefs),
        ...emptyRepositories(tasks: tasks, projects: [website]),
        linkOpenerProvider.overrideWithValue(opener),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 17, 9, 41)),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: theme == null
            ? MediaQuery(
                data: MediaQueryData(
                  size: const Size(390, 1400),
                  textScaler: TextScaler.linear(textScale),
                ),
                child: const MainApp(),
              )
            : MaterialApp(
                theme: theme,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(textScale)),
                  child: child!,
                ),
                home: const TaskDetailScreen(taskId: 7),
              ),
      ),
    );
    await tester.pumpAndSettle();
    if (theme == null) {
      container.read(appRouterProvider).push(Routes.task('7')).ignore();
      await tester.pumpAndSettle();
    }
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  TaskDetails updated() =>
      verify(() => tasks.update(captureAny())).captured.last as TaskDetails;

  testWidgets('shows everything about the task', (tester) async {
    await pumpDetail(tester);
    for (final text in [
      'Review homepage wireframes',
      'High',
      'Website redesign',
      '#design',
      '#review',
      'Check the hero.',
      'DUE THU, 19 NOV · 3:00 PM',
      'Wireframes v3',
      'SUBTASKS · 2/4',
      '50%',
      'Delete task',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
  });

  testWidgets('a bare task reads No date and Inbox', (tester) async {
    live.value = TaskDetails(
      task: task.copyWith(
        description: null,
        dueDate: null,
        dueMinute: null,
        projectId: null,
        priority: TaskPriority.medium,
      ),
    );
    await pumpDetail(tester);
    expect(find.text('NO DATE'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('High'), findsNothing);
    expect(find.textContaining('SUBTASKS'), findsNothing);
  });

  group('quick chips move the date and keep the time', () {
    for (final (chip, start, date) in [
      ('Today', WeekStart.mon, DateTime(2026, 11, 17)),
      ('Tomorrow', WeekStart.mon, DateTime(2026, 11, 18)),
      ('Next week', WeekStart.mon, DateTime(2026, 11, 23)),
      ('Next week', WeekStart.sun, DateTime(2026, 11, 22)),
      ('Next week', WeekStart.sat, DateTime(2026, 11, 21)),
    ]) {
      testWidgets('$chip with ${start.name} weeks', (tester) async {
        await prefs.update((p) => p.copyWith(weekStart: start));
        await pumpDetail(tester);
        await tapText(tester, chip);
        final task = updated().task;
        expect((task.dueDate, task.dueMinute), (date, 900));
      });
    }
  });

  testWidgets('ticking a subtask saves it and updates the count', (
    tester,
  ) async {
    await pumpDetail(tester);
    await tester.tap(
      find.byWidgetPredicate((w) => w is TaskCheckbox && w.title == 'Nav'),
    );
    await tester.pumpAndSettle();
    expect(
      [for (final s in updated().subtasks) s.done],
      [true, true, true, false],
    );
    expect(find.text('SUBTASKS · 3/4'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
  });

  testWidgets('completing shows the toast, and Undo reopens it', (
    tester,
  ) async {
    await pumpDetail(tester);
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is TaskCheckbox && w.title == 'Review homepage wireframes',
      ),
    );
    await tester.pumpAndSettle();
    verify(() => tasks.complete(7)).called(1);
    expect(
      find.text('Nice. “Review homepage wireframes” is done'),
      findsOneWidget,
    );
    expect(find.byType(TaskDetailScreen), findsOneWidget, reason: 'stays');

    await tapText(tester, 'Undo');
    verify(() => tasks.undoComplete(any())).called(1);
  });

  testWidgets('Edit opens the form for this task', (tester) async {
    await pumpDetail(tester);
    await tapText(tester, 'Edit');
    expect(
      tester.widget<TaskFormScreen>(find.byType(TaskFormScreen)).taskId,
      7,
    );
  });

  group('delete dialog', () {
    testWidgets('names the subtasks and project; Cancel keeps it', (
      tester,
    ) async {
      await pumpDetail(tester);
      await tapText(tester, 'Delete task');
      expect(find.text('Delete this task?'), findsOneWidget);
      expect(
        find.text(
          '“Review homepage wireframes” and its 4 subtasks will be removed '
          "from Website redesign. This can't be undone.",
        ),
        findsOneWidget,
      );
      await tapText(tester, 'Cancel');
      verifyNever(() => tasks.delete(any()));
      expect(find.byType(TaskDetailScreen), findsOneWidget);
    });

    testWidgets('without subtasks, in Inbox', (tester) async {
      live.value = TaskDetails(task: task.copyWith(projectId: null));
      await pumpDetail(tester);
      await tapText(tester, 'Delete task');
      expect(
        find.text(
          '“Review homepage wireframes” will be removed from Inbox. '
          "This can't be undone.",
        ),
        findsOneWidget,
      );
    });

    testWidgets('Mark as done instead completes and stays', (tester) async {
      await pumpDetail(tester);
      await tapText(tester, 'Delete task');
      await tapText(tester, 'Mark as done instead');
      verify(() => tasks.complete(7)).called(1);
      verifyNever(() => tasks.delete(any()));
      expect(find.byType(TaskDetailScreen), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('Delete task deletes and goes back', (tester) async {
      await pumpDetail(tester);
      // The delete button in the dialog, not the link behind it.
      await tapText(tester, 'Delete task');
      await tester.tap(find.text('Delete task').last);
      await tester.pumpAndSettle();
      verify(() => tasks.delete(7)).called(1);
      expect(find.byType(TaskDetailScreen), findsNothing);
    });
  });

  group('links', () {
    testWidgets('open in the browser', (tester) async {
      await pumpDetail(tester);
      await tapText(tester, 'Wireframes v3');
      verify(() => opener.open(Uri.parse('https://f.co/w'))).called(1);
      expect(find.byType(CompleteToast), findsNothing);
    });

    testWidgets('say so when they cannot open', (tester) async {
      when(() => opener.open(any())).thenAnswer((_) async => false);
      await pumpDetail(tester);
      await tapText(tester, 'Wireframes v3');
      expect(find.text("Couldn't open this link"), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });
  });

  for (final (name, theme) in [
    ('light', buildLightTheme()),
    ('dark', buildDarkTheme()),
  ]) {
    testWidgets('lays out at 200% text in $name', (tester) async {
      await pumpDetail(tester, theme: theme, textScale: 2);
      expect(tester.takeException(), isNull);
    });
  }
}
