import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/insights/presentation/insights_screen.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../projects/presentation/projects_app.dart';

void main() {
  late ProjectsApp app;

  setUpAll(registerProjectFallbacks);

  setUp(() => app = ProjectsApp());

  // Today is Tue 17 Nov 2026.
  Task task(
    int id, {
    required DateTime due,
    DateTime? doneAt,
    DateTime? created,
  }) => Task(
    id: id,
    title: 'Task $id',
    priority: TaskPriority.medium,
    status: doneAt == null ? TaskStatus.open : TaskStatus.done,
    boardColumn: doneAt == null ? BoardColumn.todo : BoardColumn.done,
    createdAt: (created ?? DateTime(2026, 10)).toUtc(),
    updatedAt: DateTime.utc(2026),
    sortOrder: id,
    dueDate: due,
    completedAt: doneAt?.toUtc(),
  );

  FocusSession session(int id, DateTime at, int minutes) => FocusSession(
    id: id,
    kind: FocusKind.focus,
    plannedSec: 1500,
    startedAt: at.toUtc(),
    elapsedSec: minutes * 60,
    completed: true,
  );

  void seed() {
    app.taskList.value = [
      // Last 7 days (11–17 Nov): 3 of 4 due are done.
      task(1, due: DateTime(2026, 11, 12), doneAt: DateTime(2026, 11, 12, 9)),
      task(2, due: DateTime(2026, 11, 12), doneAt: DateTime(2026, 11, 12, 10)),
      task(3, due: DateTime(2026, 11, 16), doneAt: DateTime(2026, 11, 16, 15)),
      task(4, due: DateTime(2026, 11, 17)),
      // The 7 before: 1 of 2.
      task(5, due: DateTime(2026, 11, 5), doneAt: DateTime(2026, 11, 5, 9)),
      task(6, due: DateTime(2026, 11, 6)),
    ];
    app.sessions.value = [
      session(1, DateTime(2026, 11, 12, 9), 25),
      session(2, DateTime(2026, 11, 16, 14), 50),
    ];
  }

  // A chart's or tile's text alternative.
  Finder label(Pattern text) => find.byWidgetPredicate(
    (w) =>
        w is Semantics &&
        switch (w.properties.label) {
          final l? => text is RegExp ? text.hasMatch(l) : l == text,
          null => false,
        },
  );

  Future<void> scrollTo(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(
        finder,
        300,
        scrollable: find.byType(Scrollable).first,
      );

  testWidgets('S34 computes the last 7 days from data', (tester) async {
    seed();
    await app.pump(tester, location: Routes.insights);

    expect(find.text('75%'), findsOneWidget);
    expect(find.text('+25 pts vs previous 7 days'), findsOneWidget);
    expect(label('Completed, 3'), findsOneWidget);
    expect(label('Streak, 1 day'), findsOneWidget);
    expect(label('Focus, 1h 15m'), findsOneWidget);
    expect(find.text('Best: Thu, 2'), findsOneWidget);
    expect(
      label(
        'Tasks completed: Wednesday 0, Thursday 2, Friday 0, Saturday 0, '
        'Sunday 0, Monday 1, Tuesday 0',
      ),
      findsOneWidget,
    );

    await scrollTo(tester, find.text('Daily avg 11 min'));
    expect(
      label(
        'Focus time: Wednesday 0 min, Thursday 25 min, Friday 0 min, '
        'Saturday 0 min, Sunday 0 min, Monday 50 min, Tuesday 0 min',
      ),
      findsOneWidget,
    );

    await scrollTo(tester, find.text('Thursday is your power day'));
    expect(
      label(
        RegExp(
          '^6-week trend: week of 12 Oct —, .*week of 9 Nov 100%, '
          r'week of 16 Nov 50%$',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('This week · 50%'), findsOneWidget);
    expect(find.text('0 pts'), findsOneWidget);
    expect(
      find.text('You finish 0.8 tasks on average, mostly before noon.'),
      findsOneWidget,
    );
  });

  testWidgets('This month compares with the same days last month', (
    tester,
  ) async {
    seed();
    await app.pump(tester, location: Routes.insights);
    await tester.tap(find.text('This month'));
    await tester.pumpAndSettle();
    expect(find.text('67%'), findsOneWidget);
    expect(find.text('Nothing was due before to compare'), findsOneWidget);
    expect(find.text('Best: 12 Nov, 2'), findsOneWidget);
  });

  testWidgets('with nothing due the rate reads —', (tester) async {
    await app.pump(tester, location: Routes.insights);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('No tasks were due'), findsOneWidget);
  });

  testWidgets('under 3 days of history: no charts, tiles still show', (
    tester,
  ) async {
    app.taskList.value = [
      task(
        1,
        due: DateTime(2026, 11, 17),
        doneAt: DateTime(2026, 11, 17, 9),
        created: DateTime(2026, 11, 16),
      ),
    ];
    await app.pump(tester, location: Routes.insights);
    expect(find.text('COMPLETED'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    await scrollTo(tester, find.text('6-WEEK TREND'));
    expect(find.text('Not enough data yet'), findsNWidgets(3));
    expect(find.textContaining('power day'), findsNothing);
  });

  testWidgets("S30's stats button opens Insights", (tester) async {
    await app.pump(tester, location: Routes.focus);
    await tester.tap(find.byTooltip('Focus stats'));
    await tester.pumpAndSettle();
    expect(find.byType(InsightsScreen), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('S34 lays out at 200% in ${brightness.name}', (tester) async {
      seed();
      await app.pump(
        tester,
        location: Routes.insights,
        brightness: brightness,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('This month'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await scrollTo(tester, find.textContaining('power day'));
      expect(tester.takeException(), isNull);
    });
  }
}
