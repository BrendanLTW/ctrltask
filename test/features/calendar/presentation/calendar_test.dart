import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/month_calendar.dart';
import 'package:ctrltask/features/calendar/presentation/calendar_providers.dart';
import 'package:ctrltask/features/calendar/presentation/calendar_week_screen.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/features/tasks/presentation/quick_add_sheet.dart';
import 'package:ctrltask/features/tasks/presentation/task_detail_screen.dart';
import 'package:ctrltask/features/tasks/presentation/tasks_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../projects/presentation/projects_app.dart';

void main() {
  late ProjectsApp app;
  // Tue 17 Nov 2026.
  final today = DateTime(2026, 11, 17);

  setUpAll(() {
    registerProjectFallbacks();
    registerFallbackValue(TaskDetails(task: testTask(0, '')));
  });

  setUp(() {
    app = ProjectsApp();
    app.active.value = [testProject(1, 'Website redesign')];
    app.taskList.value = [
      testTask(1, 'Send invoice', dueDate: DateTime(2026, 11, 16)),
      testTask(
        2,
        'Review wireframes',
        projectId: 1,
        dueDate: today,
      ).copyWith(dueMinute: 600, priority: TaskPriority.high),
      testTask(3, 'Read chapter', dueDate: today),
      testTask(4, 'Pay bill', dueDate: today, done: true).copyWith(
        dueMinute: 540,
        completedAt: DateTime(2026, 11, 17, 9).toUtc(),
      ),
      testTask(5, 'Groceries', dueDate: DateTime(2026, 11, 20)),
      testTask(6, 'Taxes', dueDate: DateTime(2026, 11, 30)),
    ];
    when(() => app.tasks.watchDetails(any())).thenAnswer((i) {
      final id = i.positionalArguments.single as int;
      return Stream.value(
        TaskDetails(task: app.taskList.value.firstWhere((t) => t.id == id)),
      );
    });
  });

  Future<void> pumpMonth(WidgetTester tester) async {
    await app.pump(tester);
    app.container.read(tasksViewModeProvider.notifier).view =
        TasksView.calendar;
    app.router.go(Routes.tasks);
    await tester.pumpAndSettle();
  }

  Future<void> pumpWeek(
    WidgetTester tester, {
    CalendarSpan span = CalendarSpan.week,
  }) async {
    await pumpMonth(tester);
    app.router.push(Routes.calendar(span)).ignore();
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  group('S21 Month', () {
    testWidgets('dots for pending, completed and overdue days', (tester) async {
      await pumpMonth(tester);
      final calendar = tester.widget<MonthCalendar>(find.byType(MonthCalendar));
      expect(calendar.dotsFor!(DateTime(2026, 11, 16)), {CalendarDot.overdue});
      expect(calendar.dotsFor!(today), {
        CalendarDot.pending,
        CalendarDot.completed,
      });
      expect(calendar.dotsFor!(DateTime(2026, 11, 20)), {CalendarDot.pending});
      expect(calendar.dotsFor!(DateTime(2026, 11, 21)), isEmpty);
      for (final text in ['Pending', 'Completed', 'Overdue']) {
        expect(find.text(text), findsOneWidget);
      }
      expect(find.textContaining('Hold & drag'), findsNothing);
    });

    testWidgets("the agenda shows the picked day's tasks", (tester) async {
      await pumpMonth(tester);
      expect(find.text('TUE, 17 NOV · TODAY'), findsOneWidget);
      expect(find.text('3 tasks'), findsOneWidget);
      expect(find.text('Review wireframes'), findsOneWidget);

      await tapText(tester, '20');
      expect(find.text('FRI, 20 NOV'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Review wireframes'), findsNothing);

      await tapText(tester, '21');
      expect(find.text('Nothing due. Tap + to plan this day'), findsOneWidget);
    });

    testWidgets('+ plans the picked day; on the list it does not', (
      tester,
    ) async {
      await pumpMonth(tester);
      await tapText(tester, '21');
      await tester.tap(find.byTooltip('Quick add task'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<QuickAddSheet>(find.byType(QuickAddSheet)).date,
        DateTime(2026, 11, 21),
      );
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      await tapText(tester, 'List');
      await tester.tap(find.byTooltip('Quick add task'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<QuickAddSheet>(find.byType(QuickAddSheet)).date,
        isNull,
      );
    });

    testWidgets('Week and Day open S22', (tester) async {
      await pumpMonth(tester);
      await tapText(tester, 'Week');
      expect(
        tester.widget<CalendarWeekScreen>(find.byType(CalendarWeekScreen)).span,
        CalendarSpan.week,
      );
      await tapText(tester, 'Month');
      expect(find.byType(CalendarWeekScreen), findsNothing);
      await tapText(tester, 'Day');
      expect(
        tester.widget<CalendarWeekScreen>(find.byType(CalendarWeekScreen)).span,
        CalendarSpan.day,
      );
    });
  });

  group('S22 Week', () {
    testWidgets('header, counts and the week strip', (tester) async {
      await pumpWeek(tester);
      expect(find.text('16 – 22 Nov'), findsOneWidget);
      // Open in the week: invoice (overdue), wireframes, chapter, groceries.
      expect(find.text('4 due · 1 overdue'), findsOneWidget);
      for (final day in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
        expect(find.text(day), findsOneWidget, reason: day);
      }
    });

    testWidgets('picking a day changes the timeline; Today comes back', (
      tester,
    ) async {
      await pumpWeek(tester);
      expect(find.text('Review wireframes'), findsOneWidget);
      await tapText(tester, '20');
      expect(find.text('Review wireframes'), findsNothing);
      expect(find.text('Groceries'), findsOneWidget, reason: 'anytime');
      expect(find.bySemanticsLabel(RegExp('^Now')), findsNothing);

      await tapText(tester, 'Today');
      expect(find.text('Review wireframes'), findsOneWidget);
    });

    testWidgets('blocks, anytime chips and the now line', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpWeek(tester);
      expect(find.text('ANYTIME'), findsOneWidget);
      expect(find.text('Read chapter'), findsOneWidget);
      expect(find.text('10:00 – 11:00 · High'), findsOneWidget);
      // Done: a slim bar, struck through, without times.
      final bill = tester.widget<Text>(find.text('Pay bill'));
      expect(bill.style!.decoration, TextDecoration.lineThrough);
      expect(find.bySemanticsLabel('Now, 9:41'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a block or anytime chip opens the task', (tester) async {
      await pumpWeek(tester);
      await tapText(tester, 'Read chapter');
      expect(
        tester.widget<TaskDetailScreen>(find.byType(TaskDetailScreen)).taskId,
        3,
      );
    });

    testWidgets('focus sessions show as merged purple blocks', (tester) async {
      FocusSession session(int id, int hour, int minute) => FocusSession(
        id: id,
        kind: FocusKind.focus,
        plannedSec: 1500,
        startedAt: DateTime(2026, 11, 17, hour, minute).toUtc(),
        endedAt: DateTime(2026, 11, 17, hour, minute + 25).toUtc(),
        elapsedSec: 1500,
        taskId: 2,
      );
      app.sessions.value = [session(1, 11, 30), session(2, 12, 0)];
      await pumpWeek(tester);
      expect(find.text('Focus · Review wireframes'), findsOneWidget);
      expect(find.text('11:30 – 12:25 · 2 sessions'), findsOneWidget);
    });

    testWidgets('Day mode drops the strip', (tester) async {
      await pumpWeek(tester, span: CalendarSpan.day);
      expect(find.text('Tue, 17 Nov'), findsOneWidget);
      expect(find.text('Mon'), findsNothing);
      expect(find.text('2 due'), findsOneWidget);
    });

    testWidgets('+ plans the picked day here too', (tester) async {
      await pumpWeek(tester);
      await tapText(tester, '19');
      await tester.tap(find.byTooltip('Quick add task'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<QuickAddSheet>(find.byType(QuickAddSheet)).date,
        DateTime(2026, 11, 19),
      );
    });
  });

  for (final brightness in Brightness.values) {
    testWidgets('S21 and S22 lay out at 200% in ${brightness.name}', (
      tester,
    ) async {
      await app.pump(tester, brightness: brightness, textScale: 2);
      app.container.read(tasksViewModeProvider.notifier).view =
          TasksView.calendar;
      app.router.go(Routes.tasks);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'S21');
      app.router.push(Routes.calendar(CalendarSpan.week)).ignore();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'S22');
    });
  }
}
