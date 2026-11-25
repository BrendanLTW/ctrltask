import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:ctrltask/core/widgets/app_shell_tab.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/features/tasks/presentation/quick_add_sheet.dart';
import 'package:ctrltask/features/tasks/presentation/task_form_screen.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:ctrltask/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/empty_repositories.dart';
import '../../../helpers/fake_preferences_repository.dart';

void main() {
  late EmptyTasks tasks;
  late DateTime now;
  final prefs = FakePreferencesRepository(
    const Preferences(
      onboardingComplete: true,
      defaultPriority: TaskPriority.high,
    ),
  );

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(const TaskDraft(title: ''));
  });

  late MemoryTags tagRepo;
  late int designTag;
  final website = Project(
    id: 7,
    name: 'Website redesign',
    colorKey: ProjectColorKey.blue,
    iconKey: ProjectIconKey.globe,
    createdAt: DateTime.utc(2026),
    sortOrder: 0,
  );

  setUp(() async {
    tagRepo = MemoryTags();
    designTag = (await tagRepo.create('design')).id;
    // Tue 17 Nov 2026, 9:41 AM.
    now = DateTime(2026, 11, 17, 9, 41);
    tasks = EmptyTasks();
    when(() => tasks.add(any())).thenAnswer(
      (i) async => Task(
        id: 1,
        title: (i.positionalArguments.single as TaskDraft).title,
        priority: TaskPriority.medium,
        status: TaskStatus.open,
        boardColumn: BoardColumn.todo,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
        sortOrder: 0,
      ),
    );
  });

  List<Override> overrides() => [
    preferencesRepositoryProvider.overrideWithValue(prefs),
    ...emptyRepositories(tasks: tasks, tagRepo: tagRepo, projects: [website]),
    clockProvider.overrideWithValue(() => now),
  ];

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: overrides(), child: const MainApp()),
    );
    await tester.pumpAndSettle();
  }

  /// Opens the sheet straight from a context, for the presets.
  Future<void> pumpSheet(
    WidgetTester tester, {
    String? title,
    DateTime? date,
    int? projectId,
    ThemeData? theme,
  }) async {
    late BuildContext context;
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          theme: theme ?? buildLightTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (c) {
              context = c;
              return const Scaffold();
            },
          ),
        ),
      ),
    );
    showQuickAdd(
      context,
      title: title,
      date: date,
      projectId: projectId,
    ).ignore();
    await tester.pumpAndSettle();
  }

  TaskDraft sent() =>
      verify(() => tasks.add(captureAny())).captured.single as TaskDraft;

  Future<void> send(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
  }

  bool selected(WidgetTester tester, String label) => tester
      .widget<AppChip>(
        find.byWidgetPredicate((w) => w is AppChip && w.label == label),
      )
      .selected;

  testWidgets('opens from every tab with the keyboard on the title', (
    tester,
  ) async {
    await pumpApp(tester);
    for (final tab in ['Tasks', 'Projects', 'Focus', 'Home']) {
      await tester.tap(
        find.byWidgetPredicate((w) => w is AppShellTab && w.label == tab),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Quick add task'));
      await tester.pumpAndSettle();

      expect(find.byType(AppSheet), findsOneWidget, reason: tab);
      expect(tester.testTextInput.hasAnyClients, isTrue, reason: tab);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('send waits for a title, trims it and closes the sheet', (
    tester,
  ) async {
    await pumpSheet(tester);
    await send(tester);
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    await send(tester);
    verifyNever(() => tasks.add(any()));

    await tester.enterText(find.byType(TextField), '  Call dentist  ');
    await tester.pump();
    await send(tester);

    final draft = sent();
    expect(draft.title, 'Call dentist');
    expect(draft.dueDate, DateTime(2026, 11, 17), reason: 'Today by default');
    expect(draft.dueMinute, isNull);
    expect(draft.priority, TaskPriority.high, reason: 'the default priority');
    expect(draft.projectId, isNull);
    expect(find.byType(AppSheet), findsNothing);
  });

  testWidgets('the title stops at 120 characters', (tester) async {
    await pumpSheet(tester);
    await tester.enterText(find.byType(TextField), 'x' * 130);
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      hasLength(120),
    );
  });

  for (final (chip, date, minute) in [
    ('No date', null, null),
    ('Today', DateTime(2026, 11, 17), null),
    ('Tomorrow · 9 AM', DateTime(2026, 11, 18), 540),
    ('Sat', DateTime(2026, 11, 21), null),
  ]) {
    testWidgets('$chip sets the date and time', (tester) async {
      await pumpSheet(tester, title: 'T');
      await tester.tap(find.text(chip));
      await tester.pump();
      await send(tester);
      final draft = sent();
      expect((draft.dueDate, draft.dueMinute), (date, minute));
    });
  }

  testWidgets('on a Saturday, Sat is next week', (tester) async {
    now = DateTime(2026, 11, 21, 10);
    await pumpSheet(tester, title: 'T');
    await tester.tap(find.text('Sat'));
    await tester.pump();
    await send(tester);
    expect(sent().dueDate, DateTime(2026, 11, 28));
  });

  testWidgets('the default priority is selected and can change', (
    tester,
  ) async {
    await pumpSheet(tester, title: 'T');
    expect(selected(tester, 'High'), isTrue);
    await tester.tap(find.text('Urgent'));
    await tester.pump();
    expect(selected(tester, 'Urgent'), isTrue);
    await send(tester);
    expect(sent().priority, TaskPriority.urgent);
  });

  testWidgets('presets show and are saved', (tester) async {
    await pumpSheet(
      tester,
      title: 'Plan my week',
      date: DateTime(2026, 11, 19),
      projectId: 3,
    );
    expect(find.text('Plan my week'), findsOneWidget);
    expect(selected(tester, 'Thu, 19 Nov'), isTrue);
    await send(tester);
    final draft = sent();
    expect(draft.title, 'Plan my week');
    expect(draft.dueDate, DateTime(2026, 11, 19));
    expect(draft.projectId, 3);
  });

  testWidgets('a preset day that has a chip selects that chip', (tester) async {
    await pumpSheet(tester, date: DateTime(2026, 11, 21));
    expect(selected(tester, 'Sat'), isTrue);
    expect(find.text('Sat, 21 Nov'), findsNothing);
  });

  testWidgets('the keyboard send key adds the task', (tester) async {
    await pumpSheet(tester);
    await tester.enterText(find.byType(TextField), 'Book flights');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(sent().title, 'Book flights');
  });

  testWidgets('More opens New task with what was typed', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Quick add task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Book flights');
    await tester.tap(find.text('Urgent'));
    await tester.pump();
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    final form = tester.widget<TaskFormScreen>(find.byType(TaskFormScreen));
    expect(form.draft?.title, 'Book flights');
    expect(form.draft?.priority, TaskPriority.urgent);
    expect(form.draft?.dueDate, DateTime(2026, 11, 17));
    verifyNever(() => tasks.add(any()));
  });

  for (final (name, theme) in [
    ('light', buildLightTheme()),
    ('dark', buildDarkTheme()),
  ]) {
    testWidgets('lays out without overflow in $name', (tester) async {
      await pumpSheet(tester, title: 'Call dentist', theme: theme);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the project chip shows its whole name in $name', (
      tester,
    ) async {
      // A Pro Max width, where everything fits with the test font.
      tester.view
        ..physicalSize = const Size(430, 932)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpSheet(tester, title: 'Call dentist', theme: theme);
      final label = tester.renderObject<RenderParagraph>(
        find.descendant(of: find.byType(AppChip), matching: find.text('Inbox')),
      );
      // On one line at its natural width: More used to squeeze it.
      expect(
        label.size.width,
        closeTo(label.getMaxIntrinsicWidth(double.infinity), 0.5),
      );
      expect(label.didExceedMaxLines, isFalse);
    });
  }

  group('hints (PRD §6.8)', () {
    Future<void> type(WidgetTester tester, String title) async {
      await tester.enterText(find.byType(EditableText), title);
      await tester.pump();
    }

    testWidgets('tomorrow 9am: shown, chosen and stripped', (tester) async {
      await pumpSheet(tester);
      await type(tester, 'Call dentist tomorrow 9am');
      expect(
        find.text('Detected tomorrow 9 AM from your words', findRichText: true),
        findsOneWidget,
      );
      expect(selected(tester, 'Tomorrow · 9 AM'), isTrue);
      await send(tester);
      final draft = sent();
      expect(draft.title, 'Call dentist');
      expect((draft.dueDate, draft.dueMinute), (DateTime(2026, 11, 18), 540));
    });

    testWidgets('priority, tag and project follow the title', (tester) async {
      await pumpSheet(tester);
      await type(tester, 'Ship it !urgent #Design @website redesign');
      expect(
        find.text(
          'Detected Urgent · #Design · Website redesign from your words',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(selected(tester, 'Urgent'), isTrue);
      expect(find.text('Website redesign'), findsOneWidget);
      await send(tester);
      final draft = sent();
      expect(draft.title, 'Ship it');
      expect(draft.priority, TaskPriority.urgent);
      expect(draft.projectId, 7);
      expect(draft.tagIds, {designTag});
    });

    testWidgets('a new #tag is created when sent', (tester) async {
      await pumpSheet(tester);
      await type(tester, 'Buy bulbs #errands');
      await send(tester);
      final errands = tagRepo.value.firstWhere((u) => u.tag.name == 'errands');
      expect(sent().tagIds, {errands.tag.id});
    });

    testWidgets('a chip tapped after a hint stands', (tester) async {
      await pumpSheet(tester);
      await type(tester, 'Gym tomorrow');
      expect(selected(tester, 'Today'), isFalse);
      await tester.tap(find.text('Today'));
      await tester.pump();
      await type(tester, 'Gym tomorrow, legs');
      expect(selected(tester, 'Today'), isTrue, reason: 'same hint');
      await send(tester);
      expect(sent().dueDate, DateTime(2026, 11, 17));
    });

    testWidgets('a hint that is deleted puts its chip back', (tester) async {
      await pumpSheet(tester);
      await type(tester, 'Gym !urgent');
      expect(selected(tester, 'Urgent'), isTrue);
      await type(tester, 'Gym');
      // Back to the default priority, High in this file's settings.
      expect(selected(tester, 'Urgent'), isFalse);
      expect(selected(tester, 'High'), isTrue);
      expect(find.textContaining('Detected', findRichText: true), findsNothing);
    });
  });
}
