import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/core/widgets/task_checkbox.dart';
import 'package:ctrltask/core/widgets/text_link.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/subtask.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/domain/task_link.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/features/tasks/presentation/task_form_screen.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/empty_repositories.dart';
import '../../../helpers/fake_preferences_repository.dart';

void main() {
  late EmptyTasks tasks;
  final website = Project(
    id: 1,
    name: 'Website redesign',
    colorKey: ProjectColorKey.blue,
    iconKey: ProjectIconKey.globe,
    createdAt: DateTime.utc(2026),
    sortOrder: 0,
  );
  final saved = Task(
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
  final details = TaskDetails(
    task: saved,
    subtasks: [
      for (final (i, t) in ['Hero', 'Pricing', 'Nav'].indexed)
        Subtask(id: i + 1, taskId: 7, title: t, sortOrder: i),
    ],
    links: const [
      TaskLink(id: 5, taskId: 7, title: 'Figma', url: 'https://figma.com'),
    ],
  );

  setUpAll(() async {
    await initializeDateFormatting('en');
    registerFallbackValue(const TaskDraft(title: ''));
    registerFallbackValue(details);
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    tasks = EmptyTasks();
    when(() => tasks.add(any())).thenAnswer((_) async => saved);
    when(() => tasks.update(any())).thenAnswer((_) async {});
    when(() => tasks.watchDetails(7)).thenAnswer((_) => Stream.value(details));
  });

  /// Opens the form over a home screen, so Cancel and Save can pop.
  Future<void> pumpForm(
    WidgetTester tester, {
    TaskDraft? draft,
    int? taskId,
    ThemeData? theme,
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = const Size(390, 1400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(
            FakePreferencesRepository(),
          ),
          ...emptyRepositories(tasks: tasks, projects: [website]),
        ],
        child: MaterialApp(
          theme: theme ?? buildLightTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        TaskFormScreen(draft: draft, taskId: taskId),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  bool saveEnabled(WidgetTester tester) =>
      tester
          .widget<TextLink>(
            find.byWidgetPredicate((w) => w is TextLink && w.label == 'Save'),
          )
          .onPressed !=
      null;

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  testWidgets('a blank title keeps Save disabled', (tester) async {
    await pumpForm(tester);
    expect(find.text('New task'), findsOneWidget);
    expect(saveEnabled(tester), isFalse);
    await tester.enterText(find.byType(TextField).first, '   ');
    await tester.pump();
    expect(saveEnabled(tester), isFalse);
  });

  testWidgets('a draft from quick add is prefilled and saved', (tester) async {
    await pumpForm(
      tester,
      draft: TaskDraft(
        title: 'Book flights',
        dueDate: DateTime(2026, 11, 19),
        dueMinute: 540,
        priority: TaskPriority.urgent,
        projectId: 1,
      ),
    );
    expect(find.text('Book flights'), findsOneWidget);
    expect(find.text('Thu, 19 Nov · 9:00 AM'), findsOneWidget);
    expect(find.text('Website redesign'), findsOneWidget);

    await tapText(tester, 'Add subtask');
    await tester.enterText(find.byType(TextField).last, 'Compare fares');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('SUBTASKS · 0/1'), findsOneWidget);

    await tapText(tester, 'Save');
    final draft =
        verify(() => tasks.add(captureAny())).captured.single as TaskDraft;
    expect(draft.title, 'Book flights');
    expect((draft.dueDate, draft.dueMinute), (DateTime(2026, 11, 19), 540));
    expect(draft.priority, TaskPriority.urgent);
    expect(draft.projectId, 1);
    expect(draft.subtasks, ['Compare fares']);
    expect(find.byType(TaskFormScreen), findsNothing, reason: 'popped');
  });

  testWidgets('a subtask ticked on a new task is saved ticked', (tester) async {
    when(() => tasks.watchDetails(7)).thenAnswer(
      (_) => Stream.value(
        TaskDetails(
          task: saved,
          subtasks: const [
            Subtask(id: 9, taskId: 7, title: 'Step', sortOrder: 0),
          ],
        ),
      ),
    );
    await pumpForm(tester, draft: const TaskDraft(title: 'T'));
    await tapText(tester, 'Add subtask');
    await tester.enterText(find.byType(TextField).last, 'Step');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TaskCheckbox));
    await tester.pumpAndSettle();
    expect(find.text('SUBTASKS · 1/1'), findsOneWidget);

    await tapText(tester, 'Save');
    final updated =
        verify(() => tasks.update(captureAny())).captured.single as TaskDetails;
    expect(updated.subtasks.first.done, isTrue);
  });

  testWidgets('a link must be http or https', (tester) async {
    await pumpForm(tester, draft: const TaskDraft(title: 'T'));
    await tapText(tester, 'Add a note or link');
    final add = find.byType(PrimaryButton);
    expect(tester.widget<PrimaryButton>(add).onPressed, isNull);

    await tester.enterText(find.byType(TextField).last, 'figma.com/file');
    await tester.pump();
    expect(
      find.text('Use a link that starts with http:// or https://'),
      findsOneWidget,
    );
    expect(tester.widget<PrimaryButton>(add).onPressed, isNull);

    await tester.enterText(find.byType(TextField).last, 'https://figma.com');
    await tester.pump();
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.text('https://figma.com'), findsNWidgets(2));

    await tapText(tester, 'Save');
    final draft =
        verify(() => tasks.add(captureAny())).captured.single as TaskDraft;
    expect(draft.links, [
      (title: 'https://figma.com', url: 'https://figma.com'),
    ]);
  });

  testWidgets('edit loads every field and saves changes', (tester) async {
    await pumpForm(tester, taskId: 7);
    expect(find.text('Edit task'), findsOneWidget);
    expect(find.text('Review homepage wireframes'), findsOneWidget);
    expect(find.text('Check the hero.'), findsOneWidget);
    expect(find.text('Thu, 19 Nov · 3:00 PM'), findsOneWidget);
    expect(find.text('SUBTASKS · 0/3'), findsOneWidget);
    expect(find.text('Figma'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Review wireframes');
    await tester.tap(find.text('Low'));
    await tester.tap(find.byTooltip('Remove subtask').at(1));
    await tester.pumpAndSettle();
    await tapText(tester, 'Add subtask');
    await tester.enterText(find.byType(TextField).last, 'Footer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove link'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Save');

    final updated =
        verify(() => tasks.update(captureAny())).captured.single as TaskDetails;
    expect(updated.task.id, 7);
    expect(updated.task.title, 'Review wireframes');
    expect(updated.task.priority, TaskPriority.low);
    expect(
      [for (final s in updated.subtasks) (s.id, s.title)],
      [(1, 'Hero'), (3, 'Nav'), (0, 'Footer')],
    );
    expect([for (final s in updated.subtasks) s.sortOrder], [0, 1, 2]);
    expect(updated.links, isEmpty);
    verifyNever(() => tasks.add(any()));
  });

  testWidgets('Cancel leaves without saving', (tester) async {
    await pumpForm(tester, draft: const TaskDraft(title: 'T'));
    await tapText(tester, 'Cancel');
    expect(find.byType(TaskFormScreen), findsNothing);
    verifyNever(() => tasks.add(any()));
    verifyNever(() => tasks.update(any()));
  });

  testWidgets('no more subtasks can be added after 50', (tester) async {
    await pumpForm(
      tester,
      draft: TaskDraft(title: 'T', subtasks: List.filled(50, 'step')),
    );
    expect(find.text('Add subtask'), findsNothing);
  });

  for (final (name, theme) in [
    ('light', buildLightTheme()),
    ('dark', buildDarkTheme()),
  ]) {
    testWidgets('edit lays out at 200% text in $name', (tester) async {
      await pumpForm(tester, taskId: 7, theme: theme, textScale: 2);
      expect(tester.takeException(), isNull);
    });
  }
}
