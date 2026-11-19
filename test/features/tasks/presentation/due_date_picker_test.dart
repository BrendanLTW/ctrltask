import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/core/widgets/quick_date_tiles.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/features/tasks/presentation/due_date_picker.dart';
import 'package:ctrltask/features/tasks/presentation/quick_add_sheet.dart';
import 'package:ctrltask/features/tasks/presentation/task_detail_screen.dart';
import 'package:ctrltask/features/tasks/presentation/task_form_screen.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/empty_repositories.dart';
import '../../../helpers/fake_preferences_repository.dart';

void main() {
  late EmptyTasks tasks;
  late DateTime now;
  late WeekStart weekStart;
  final task = Task(
    id: 7,
    title: 'Slides',
    priority: TaskPriority.medium,
    status: TaskStatus.open,
    boardColumn: BoardColumn.todo,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    sortOrder: 0,
    dueDate: DateTime(2026, 11, 19),
    dueMinute: 900,
  );

  setUpAll(() {
    registerFallbackValue(const TaskDraft(title: ''));
    registerFallbackValue(TaskDetails(task: task));
  });

  setUp(() {
    // Tue 17 Nov 2026, 9:41 AM.
    now = DateTime(2026, 11, 17, 9, 41);
    weekStart = WeekStart.mon;
    tasks = EmptyTasks();
    when(() => tasks.add(any())).thenAnswer((_) async => task);
    when(() => tasks.update(any())).thenAnswer((_) async {});
    when(() => tasks.watchDetails(7))
        .thenAnswer((_) => Stream.value(TaskDetails(task: task)));
  });

  /// [home] gets a context to open things from.
  Future<BuildContext> pumpHost(
    WidgetTester tester, {
    Widget? home,
    ThemeData? theme,
  }) async {
    tester.view
      ..physicalSize = const Size(390, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    late BuildContext context;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(
            FakePreferencesRepository(Preferences(weekStart: weekStart)),
          ),
          ...emptyRepositories(tasks: tasks),
          clockProvider.overrideWithValue(() => now),
        ],
        child: MaterialApp(
          theme: theme ?? buildLightTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (c) {
              context = c;
              return home ?? const Scaffold();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return context;
  }

  /// Opens the picker and returns what it resolves to once [act] has run.
  Future<DueChoice?> pick(
    WidgetTester tester,
    Future<void> Function() act, {
    DateTime? date,
    int? minute,
  }) async {
    final context = await pumpHost(tester);
    final result = showDueDatePicker(context, date: date, minute: minute);
    await tester.pumpAndSettle();
    await act();
    await tester.pumpAndSettle();
    return await result;
  }

  /// Scrolls chips in sideways rows into view first.
  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<void> set(WidgetTester tester) async {
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
  }

  testWidgets('starts on today with no time', (tester) async {
    final context = await pumpHost(tester);
    showDueDatePicker(context).ignore();
    await tester.pumpAndSettle();
    expect(find.text('Set Tue, 17 Nov'), findsOneWidget);
    expect(
      tester
          .widget<QuickDateTiles<DateTime>>(
            find.byType(QuickDateTiles<DateTime>),
          )
          .selected,
      DateTime(2026, 11, 17),
    );
    expect(
      tester
          .widget<AppChip>(
            find.byWidgetPredicate((w) => w is AppChip && w.label == 'No time'),
          )
          .selected,
      isTrue,
    );
  });

  for (final (tile, start, date) in [
    ('Today', WeekStart.mon, DateTime(2026, 11, 17)),
    ('Tomorrow', WeekStart.mon, DateTime(2026, 11, 18)),
    ('Weekend', WeekStart.mon, DateTime(2026, 11, 21)),
    ('Next week', WeekStart.mon, DateTime(2026, 11, 23)),
    ('Next week', WeekStart.sun, DateTime(2026, 11, 22)),
  ]) {
    testWidgets('$tile with ${start.name} weeks', (tester) async {
      weekStart = start;
      final choice = await pick(tester, () async {
        await tapText(tester, tile);
        await set(tester);
      });
      expect(choice, (date: date, minute: null));
    });
  }

  testWidgets('Weekend on a Saturday is next Saturday', (tester) async {
    now = DateTime(2026, 11, 21, 10);
    final choice = await pick(tester, () async {
      await tapText(tester, 'Weekend');
      await set(tester);
    });
    expect(choice?.date, DateTime(2026, 11, 28));
  });

  testWidgets('a day in the calendar, this month or the next', (tester) async {
    final choice = await pick(tester, () async {
      await tapText(tester, '24');
      expect(find.text('Set Tue, 24 Nov'), findsOneWidget);
      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();
      await tapText(tester, '9');
      await set(tester);
    });
    expect(choice?.date, DateTime(2026, 12, 9));
  });

  testWidgets('a time chip sets the time and the button reads it back', (
    tester,
  ) async {
    final choice = await pick(tester, date: DateTime(2026, 11, 19), () async {
      await tapText(tester, '3:00 PM');
      expect(find.text('Set Thu, 19 Nov · 3:00 PM'), findsOneWidget);
      await set(tester);
    });
    expect(choice, (date: DateTime(2026, 11, 19), minute: 900));
  });

  testWidgets('No time clears it', (tester) async {
    final choice = await pick(
      tester,
      date: DateTime(2026, 11, 19),
      minute: 900,
      () async {
        await tapText(tester, 'No time');
        await set(tester);
      },
    );
    expect(choice?.minute, isNull);
  });

  testWidgets('an unusual time keeps its own chip', (tester) async {
    final choice = await pick(
      tester,
      date: DateTime(2026, 11, 19),
      minute: 10 * 60 + 30,
      () async {
        expect(
          tester
              .widget<AppChip>(
                find.byWidgetPredicate(
                  (w) => w is AppChip && w.label == '10:30 AM',
                ),
              )
              .selected,
          isTrue,
        );
        await set(tester);
      },
    );
    expect(choice?.minute, 630);
  });

  testWidgets('closing picks nothing', (tester) async {
    final choice = await pick(tester, () async {
      await tester.tap(find.byTooltip('Close'));
    });
    expect(choice, isNull);
  });

  testWidgets('S11: the Due row opens the picker', (tester) async {
    await pumpHost(
      tester,
      home: const TaskFormScreen(draft: TaskDraft(title: 'T')),
    );
    await tapText(tester, 'Due');
    await tapText(tester, 'Tomorrow');
    await tapText(tester, '9:00 AM');
    await set(tester);
    expect(find.text('Wed, 18 Nov · 9:00 AM'), findsOneWidget);
  });

  testWidgets('S12: Pick saves the new date and time', (tester) async {
    await pumpHost(tester, home: const TaskDetailScreen(taskId: 7));
    await tapText(tester, 'Pick');
    await tapText(tester, '20');
    await tapText(tester, '6:00 PM');
    await set(tester);
    final saved =
        verify(() => tasks.update(captureAny())).captured.single as TaskDetails;
    expect(
      (saved.task.dueDate, saved.task.dueMinute),
      (DateTime(2026, 11, 20), 18 * 60),
    );
  });

  testWidgets('S10: Pick adds its own chip and is sent', (tester) async {
    final context = await pumpHost(tester);
    showQuickAdd(context, title: 'Call').ignore();
    await tester.pumpAndSettle();
    await tapText(tester, 'Pick');
    await tapText(tester, '20');
    await tapText(tester, '3:00 PM');
    await set(tester);
    expect(
      tester
          .widget<AppChip>(
            find.byWidgetPredicate(
              (w) => w is AppChip && w.label == 'Fri, 20 Nov · 3 PM',
            ),
          )
          .selected,
      isTrue,
    );
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
    final draft =
        verify(() => tasks.add(captureAny())).captured.single as TaskDraft;
    expect((draft.dueDate, draft.dueMinute), (DateTime(2026, 11, 20), 900));
  });

  for (final (name, theme) in [
    ('light', buildLightTheme()),
    ('dark', buildDarkTheme()),
  ]) {
    testWidgets('lays out without overflow in $name', (tester) async {
      final context = await pumpHost(tester, theme: theme);
      showDueDatePicker(context).ignore();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
