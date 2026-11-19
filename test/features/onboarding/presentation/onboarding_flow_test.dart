import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/features/onboarding/presentation/all_set_screen.dart';
import 'package:ctrltask/features/onboarding/presentation/first_task_screen.dart';
import 'package:ctrltask/features/onboarding/presentation/name_screen.dart';
import 'package:ctrltask/features/onboarding/presentation/reminders_screen.dart';
import 'package:ctrltask/features/onboarding/presentation/splash_screen.dart';
import 'package:ctrltask/features/onboarding/presentation/welcome_screen.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:ctrltask/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/empty_repositories.dart';
import '../../../helpers/fake_preferences_repository.dart';

void main() {
  late FakePreferencesRepository prefs;
  late EmptyTasks tasks;
  final now = DateTime(2026, 11, 17, 9, 41);

  Task taskFrom(TaskDraft d) => Task(
    id: 1,
    title: d.title.trim(),
    priority: d.priority,
    status: TaskStatus.open,
    boardColumn: BoardColumn.todo,
    createdAt: now.toUtc(),
    updatedAt: now.toUtc(),
    sortOrder: 0,
    dueDate: d.dueDate,
  );

  setUpAll(() {
    registerFallbackValue(const TaskDraft(title: ''));
    registerFallbackValue(
      TaskDetails(task: taskFrom(const TaskDraft(title: 'x'))),
    );
  });

  setUp(() {
    prefs = FakePreferencesRepository(
      const Preferences(defaultPriority: TaskPriority.high),
    );
    tasks = EmptyTasks();
    when(() => tasks.add(any())).thenAnswer(
      (i) async => taskFrom(i.positionalArguments.single as TaskDraft),
    );
    when(() => tasks.watchDetails(any())).thenAnswer(
      (_) => Stream.value(
        TaskDetails(task: taskFrom(const TaskDraft(title: 'old'))),
      ),
    );
    when(() => tasks.update(any())).thenAnswer((_) async {});
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(prefs),
          ...emptyRepositories(tasks: tasks),
          clockProvider.overrideWithValue(() => now),
        ],
        child: const MainApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  bool enabled(WidgetTester tester) =>
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed !=
      null;

  testWidgets('the whole flow saves every choice and lands on Home', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    await tapText(tester, 'Get started');

    // S03: Continue waits for a name; the name is trimmed.
    expect(find.byType(NameScreen), findsOneWidget);
    expect(enabled(tester), isFalse);
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(enabled(tester), isFalse);
    await tester.enterText(find.byType(TextField), '  Alex  ');
    await tester.pump();
    await tapText(tester, 'Continue');
    expect((await prefs.read()).userName, 'Alex');

    // S04 greets by name; Back keeps what was typed.
    expect(
      find.text("What's one thing to get done today, Alex?"),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, '  Alex  '), findsOneWidget);
    await tapText(tester, 'Continue');

    // A suggestion fills the field; Tomorrow sets the date.
    await tapText(tester, 'Plan my week');
    await tapText(tester, 'Tomorrow');
    await tapText(tester, 'Add task');
    final draft =
        verify(() => tasks.add(captureAny())).captured.single as TaskDraft;
    expect(draft.title, 'Plan my week');
    expect(draft.dueDate, DateTime(2026, 11, 18));
    expect(draft.priority, TaskPriority.high, reason: 'the default priority');
    expect(draft.projectId, isNull);

    // S05: choices are saved by Not now.
    expect(find.byType(RemindersScreen), findsOneWidget);
    await tapText(tester, 'Overdue nudges');
    await tapText(tester, '9:00');
    await tapText(tester, 'Not now');
    final saved = await prefs.read();
    expect(saved.overdueOn, isTrue);
    expect(saved.dailyPlanMinute, 9 * 60);
    expect(saved.remindersOn, isTrue);

    // S06 sums it up.
    expect(find.byType(AllSetScreen), findsOneWidget);
    expect(find.text("You're all set, Alex"), findsOneWidget);
    for (final value in ['Alex', 'Plan my week', '9:00 AM', 'Monday']) {
      expect(find.text(value), findsOneWidget, reason: value);
    }
    await tapText(tester, 'Go to Today');
    expect((await prefs.read()).onboardingComplete, isTrue);
    expect(find.byType(AllSetScreen), findsNothing);
    expect(find.byTooltip('Quick add task'), findsOneWidget);
  });

  testWidgets('going back and adding again updates the first task', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapText(tester, 'Get started');
    await tester.enterText(find.byType(TextField), 'Alex');
    await tester.pump();
    await tapText(tester, 'Continue');
    await tester.enterText(find.byType(TextField), 'Book flights');
    await tester.pump();
    await tapText(tester, 'Add task');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Book flights'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Book trains');
    await tester.pump();
    await tapText(tester, 'Add task');

    verify(() => tasks.add(any())).called(1);
    final details =
        verify(() => tasks.update(captureAny())).captured.single as TaskDetails;
    expect(details.task.title, 'Book trains');
  });

  testWidgets('skipping leaves the name empty and adds no task', (
    tester,
  ) async {
    await prefs.update((p) => p.copyWith(userName: 'Old name'));
    await pumpApp(tester);
    await tapText(tester, 'Get started');
    await tapText(tester, 'Skip');
    expect((await prefs.read()).userName, isEmpty);
    expect(find.text("What's one thing to get done today?"), findsOneWidget);

    await tapText(tester, "I'll do it later");
    await tapText(tester, 'Skip');
    verifyNever(() => tasks.add(any()));
    expect(find.text("You're all set"), findsOneWidget);
    expect(
      find.text("Add your first task from Today whenever you're ready."),
      findsOneWidget,
    );
    expect(find.text('—'), findsNWidgets(2));
  });

  testWidgets('the name is kept to 30 characters', (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'Get started');
    await tester.enterText(find.byType(TextField), 'x' * 40);
    await tester.pump();
    await tapText(tester, 'Continue');
    expect((await prefs.read()).userName, 'x' * 30);
  });

  testWidgets('Create a project first finishes onboarding on Projects', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapText(tester, 'Get started');
    await tapText(tester, 'Skip');
    await tapText(tester, "I'll do it later");
    await tapText(tester, 'Not now');
    await tapText(tester, 'Create a project first');
    expect((await prefs.read()).onboardingComplete, isTrue);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Projects')),
      findsOneWidget,
    );
  });

  for (final (name, theme) in [
    ('light', buildLightTheme()),
    ('dark', buildDarkTheme()),
  ]) {
    testWidgets('every screen lays out without overflow in $name', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final screen in const <Widget>[
        SplashScreen(),
        WelcomeScreen(),
        NameScreen(),
        FirstTaskScreen(),
        RemindersScreen(),
        AllSetScreen(),
      ]) {
        await tester.pumpWidget(
          ProviderScope(
            key: UniqueKey(),
            overrides: [
              preferencesRepositoryProvider.overrideWithValue(prefs),
              taskRepositoryProvider.overrideWithValue(tasks),
            ],
            child: MaterialApp(
              theme: theme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: screen,
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '${screen.runtimeType}');
      }
      // Lets the splash's bar finish without a router to leave to.
      await tester.pumpWidget(const SizedBox());
    });
  }
}
