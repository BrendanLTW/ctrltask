import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/haptics/haptics.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/alert_banner.dart';
import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:ctrltask/core/widgets/complete_toast.dart';
import 'package:ctrltask/core/widgets/progress_ring.dart';
import 'package:ctrltask/core/widgets/task_card.dart';
import 'package:ctrltask/core/widgets/task_checkbox.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_session_repository.dart';
import 'package:ctrltask/features/home/presentation/home_all_done.dart';
import 'package:ctrltask/features/home/presentation/home_first_run.dart';
import 'package:ctrltask/features/home/presentation/home_header.dart';
import 'package:ctrltask/features/home/presentation/home_screen.dart';
import 'package:ctrltask/features/home/presentation/home_stats.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/domain/project_repository.dart';
import 'package:ctrltask/features/projects/presentation/project_form_screen.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:ctrltask/l10n/date_text.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:ctrltask/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/live.dart';

class _Tasks extends Mock implements TaskRepository;

class _Projects extends Mock implements ProjectRepository;

class _Focus extends Mock implements FocusSessionRepository;

class _Haptics extends Mock implements Haptics;

final _now = DateTime(2026, 11, 17, 9, 41);
final _today = DateTime(2026, 11, 17);

Task _task(
  int id,
  String title, {
  TaskPriority priority = TaskPriority.medium,
  DateTime? due,
  int? minute,
  int? projectId,
  DateTime? completedAt,
}) => Task(
  id: id,
  title: title,
  priority: priority,
  status: completedAt == null ? TaskStatus.open : TaskStatus.done,
  boardColumn: completedAt == null ? BoardColumn.todo : BoardColumn.done,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  sortOrder: id,
  dueDate: due,
  dueMinute: minute,
  projectId: projectId,
  completedAt: completedAt?.toUtc(),
);

void main() {
  late _Tasks tasks;
  late _Haptics haptics;
  late Live<List<Task>> today;
  late Live<List<Task>> all;
  late FakePreferencesRepository prefs;

  final website = Project(
    id: 1,
    name: 'Website redesign',
    colorKey: ProjectColorKey.blue,
    iconKey: ProjectIconKey.globe,
    createdAt: DateTime.utc(2026),
    sortOrder: 0,
    deadline: DateTime(2026, 11, 30),
  );

  final slides = _task(
    10,
    'Finish Q4 revenue slides',
    priority: TaskPriority.urgent,
    due: _today,
    minute: 17 * 60,
  );
  final wireframes = _task(
    11,
    'Review homepage wireframes',
    priority: TaskPriority.high,
    due: _today,
    minute: 600,
    projectId: 1,
  );
  final bill = _task(
    12,
    'Pay TNB electricity bill',
    due: _today,
    minute: 540,
    completedAt: DateTime(2026, 11, 17, 9, 5),
  );
  final invoice = _task(
    13,
    'Send invoice to Lumen Studio',
    priority: TaskPriority.high,
    due: DateTime(2026, 11, 16),
  );
  final hero = _task(14, 'Write hero copy', due: DateTime(2026, 11, 19));

  setUpAll(() async {
    await initializeDateFormatting('en');
    registerFallbackValue(DateTime(2026));
    registerFallbackValue((before: TaskDetails(task: slides), nextId: null));
  });

  setUp(() {
    today = Live([slides, wireframes, bill]);
    all = Live([slides, wireframes, bill, invoice, hero]);
    prefs = FakePreferencesRepository(
      const Preferences(userName: 'Alex', onboardingComplete: true),
    );
    tasks = _Tasks();
    haptics = _Haptics();
    when(() => haptics.light()).thenAnswer((_) async {});
    when(() => tasks.watchToday(any())).thenAnswer((_) => today.stream);
    when(() => tasks.watchAll(includeDone: any(named: 'includeDone')))
        .thenAnswer((i) {
          final includeDone = i.namedArguments[#includeDone] as bool? ?? false;
          return all.stream.map(
            (l) => [
              for (final t in l)
                if (includeDone || t.status == TaskStatus.open) t,
            ],
          );
        });
    when(
      () => tasks.watchSubtaskProgress(),
    ).thenAnswer((_) => Stream.value(<int, Progress>{11: (done: 2, total: 4)}));
    when(() => tasks.complete(any())).thenAnswer((i) async {
      final id = i.positionalArguments.single as int;
      Task done(Task t) => t.id == id
          ? t.copyWith(
              status: TaskStatus.done,
              boardColumn: BoardColumn.done,
              completedAt: _now.toUtc(),
            )
          : t;
      final before = today.value.firstWhere((t) => t.id == id);
      today.value = [for (final t in today.value) done(t)];
      all.value = [for (final t in all.value) done(t)];
      return (before: TaskDetails(task: before), nextId: null);
    });
    when(() => tasks.undoComplete(any())).thenAnswer((i) async {
      final before = (i.positionalArguments.single as Completion).before.task;
      Task back(Task t) => t.id == before.id ? before : t;
      today.value = [for (final t in today.value) back(t)];
      all.value = [for (final t in all.value) back(t)];
    });
    when(() => tasks.uncomplete(any())).thenAnswer((_) async {});
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    ThemeData? theme,
    List<FocusSession> sessions = const [],
  }) async {
    tester.view
      ..physicalSize = const Size(390, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final projects = _Projects();
    when(projects.watchActive).thenAnswer((_) => Stream.value([website]));
    final focus = _Focus();
    when(() => focus.watchStartedBetween(any(), any()))
        .thenAnswer((_) => Stream.value(sessions));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(prefs),
          taskRepositoryProvider.overrideWithValue(tasks),
          projectRepositoryProvider.overrideWithValue(projects),
          focusSessionRepositoryProvider.overrideWithValue(focus),
          hapticsProvider.overrideWithValue(haptics),
          clockProvider.overrideWithValue(() => _now),
        ],
        child: theme == null
            ? const MainApp()
            : MaterialApp(
                theme: theme,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const HomeScreen(),
              ),
      ),
    );
    await tester.pumpAndSettle();
  }

  tearDown(hideCompleteToast);

  for (final (name, theme) in [
    ('light', buildLightTheme()),
    ('dark', buildDarkTheme()),
  ]) {
    testWidgets('every section shows the live figures in $name', (
      tester,
    ) async {
      await pumpHome(
        tester,
        theme: theme,
        sessions: [
          FocusSession(
            id: 1,
            kind: FocusKind.focus,
            plannedSec: 1500,
            startedAt: DateTime(2026, 11, 17, 8).toUtc(),
            elapsedSec: 4500,
          ),
          // A break and a too-short session don't count.
          FocusSession(
            id: 2,
            kind: FocusKind.short,
            plannedSec: 300,
            startedAt: DateTime(2026, 11, 17, 8).toUtc(),
            elapsedSec: 300,
          ),
          FocusSession(
            id: 3,
            kind: FocusKind.focus,
            plannedSec: 1500,
            startedAt: DateTime(2026, 11, 17, 9).toUtc(),
            elapsedSec: 59,
          ),
        ],
      );

      expect(find.text('TUE, 17 NOVEMBER'), findsOneWidget);
      expect(find.text('Good morning, Alex'), findsOneWidget);
      expect(find.text('1 of 3 done', findRichText: true), findsOneWidget);
      expect(
        find.text('2 left · next: Review homepage wireframes, 10:00 AM'),
        findsOneWidget,
      );
      expect(find.text('1h 15m', findRichText: true), findsOneWidget);
      expect(find.text('1 overdue task'), findsOneWidget);
      expect(
        find.text('Send invoice to Lumen Studio · was due yesterday'),
        findsOneWidget,
      );
      expect(find.text('DUE TODAY'), findsOneWidget);
      final cards = tester.widgetList<TaskCard>(find.byType(TaskCard));
      expect(
        [for (final c in cards) c.data.title],
        [
          'Finish Q4 revenue slides',
          'Review homepage wireframes',
          'Pay TNB electricity bill',
        ],
      );
      expect(cards.elementAt(1).data.projectName, 'Website redesign');
      expect(cards.elementAt(1).data.subtasks, (done: 2, total: 4));
      expect(find.text('UPCOMING DEADLINES'), findsOneWidget);
      expect(find.text('Write hero copy'), findsOneWidget);
      expect(find.text('Website redesign'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the hero reads the ring as "1 of 3 tasks done today"', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpHome(tester);
    expect(
      tester.getSemantics(find.byType(ProgressRing)).label,
      contains('1 of 3 tasks done today'),
    );
    handle.dispose();
  });

  testWidgets('the banner hides with nothing overdue and counts several', (
    tester,
  ) async {
    all.value = [slides, wireframes, bill];
    await pumpHome(tester);
    expect(find.byType(AlertBanner), findsNothing);

    all.value = [slides, invoice, _task(20, 'Old', due: DateTime(2026, 11, 2))];
    await tester.pumpAndSettle();
    expect(find.text('2 overdue tasks'), findsOneWidget);
  });

  testWidgets('ticking completes with a haptic, toast and Undo', (
    tester,
  ) async {
    await pumpHome(tester);

    await tester.tap(find.byType(TaskCheckbox).first);
    await tester.pumpAndSettle();

    verify(() => tasks.complete(slides.id)).called(1);
    verify(() => haptics.light()).called(1);
    expect(
      find.text('Nice. “Finish Q4 revenue slides” is done'),
      findsOneWidget,
    );
    expect(find.text('2 of 3 done', findRichText: true), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    verify(() => tasks.undoComplete(any())).called(1);
    expect(find.text('1 of 3 done', findRichText: true), findsOneWidget);
    expect(find.byType(CompleteToast), findsNothing);
  });

  testWidgets('ticking a done task reopens it without a toast', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byType(TaskCheckbox).last);
    await tester.pumpAndSettle();
    verify(() => tasks.uncomplete(bill.id)).called(1);
    verifyNever(() => tasks.complete(any()));
    expect(find.byType(CompleteToast), findsNothing);
  });

  testWidgets('search and the avatar open their screens', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byTooltip('Search tasks'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Search')),
      findsOneWidget,
    );
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Settings')),
      findsOneWidget,
    );
  });

  group('states', () {
    Finder appBarTitle(String text) =>
        find.descendant(of: find.byType(AppBar), matching: find.text(text));

    testWidgets('no tasks at all is the S08 blank page', (tester) async {
      today.value = [];
      all.value = [];
      await pumpHome(tester);

      expect(find.byType(HomeFirstRun), findsOneWidget);
      expect(find.text('Welcome, Alex'), findsOneWidget);
      expect(find.byTooltip('Search tasks'), findsNothing);
      expect(find.text('Nothing planned'), findsOneWidget);
      expect(find.byType(HomeStats), findsNothing);

      // The chip opens quick add with its title.
      await tester.tap(find.text('Plan my week'));
      await tester.pumpAndSettle();
      expect(find.byType(AppSheet), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Plan my week'), findsOneWidget);
    });

    testWidgets('Create a project opens New project', (tester) async {
      today.value = [];
      all.value = [];
      await pumpHome(tester);
      await tester.tap(find.text('Create a project'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormScreen), findsOneWidget);
    });

    testWidgets('tasks on other days keep the normal layout', (tester) async {
      today.value = [];
      all.value = [hero];
      await pumpHome(tester);
      expect(find.byType(HomeFirstRun), findsNothing);
      expect(find.byType(HomeStats), findsOneWidget);
      expect(find.text('Good morning, Alex'), findsOneWidget);
    });

    testWidgets('every task done is S09, with tomorrow below', (tester) async {
      final finished = [
        bill,
        slides.copyWith(
          status: TaskStatus.done,
          boardColumn: BoardColumn.done,
          completedAt: DateTime(2026, 11, 17, 8).toUtc(),
        ),
      ];
      final tomorrow = _task(30, 'Order tiles', due: DateTime(2026, 11, 18));
      today.value = finished;
      all.value = [...finished, tomorrow];
      await pumpHome(tester);

      expect(find.byType(DayDoneCard), findsOneWidget);
      expect(find.byType(HomeStats), findsNothing);
      expect(find.text('Day done. Nice work.'), findsOneWidget);
      expect(
        find.text(
          '2 tasks finished. Your streak is now 1 day.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('TOMORROW · WED 18'), findsOneWidget);
      expect(find.text('Order tiles'), findsOneWidget);
      expect(
        find.textContaining('Any time', findRichText: true),
        findsOneWidget,
      );

      await tester.tap(find.text('Plan tomorrow'));
      await tester.pumpAndSettle();
      expect(appBarTitle('Tasks'), findsOneWidget);
    });
  });

  test('the day-done summary reads naturally', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(
      l10n.dayDoneTasks(6, l10n.durationLabel(const Duration(minutes: 125))),
      '6 tasks finished and 2h 05m of focus.',
    );
    expect(l10n.dayDoneTasksOnly(1), '1 task finished.');
    expect(
      l10n.dayDoneStreak(l10n.dayCount(13)),
      'Your streak is now 13 days.',
    );
  });

  test('the greeting follows the time of day and the name', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    DateTime at(int h, int m) => DateTime(2026, 11, 17, h, m);
    expect(greeting(l10n, at(11, 59), 'Alex'), 'Good morning, Alex');
    expect(greeting(l10n, at(12, 0), 'Alex'), 'Good afternoon, Alex');
    expect(greeting(l10n, at(17, 59), 'Alex'), 'Good afternoon, Alex');
    expect(greeting(l10n, at(18, 0), 'Alex'), 'Good evening, Alex');
    expect(greeting(l10n, at(7, 0), ''), 'Good morning');
  });
}
