import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/presentation/reminder_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../projects/presentation/projects_app.dart';

void main() {
  late ProjectsApp app;
  // Thu 19 Nov 2026.
  final thursday = DateTime(2026, 11, 19);
  TaskDetails? saved;

  setUpAll(() {
    registerProjectFallbacks();
    registerFallbackValue(TaskDetails(task: testTask(0, '')));
  });

  void task(Task t) {
    saved = null;
    app.taskList.value = [t];
  }

  setUp(() {
    app = ProjectsApp();
    task(
      testTask(
        1,
        'Review wireframes',
        dueDate: thursday,
      ).copyWith(dueMinute: 900, reminder: ReminderOffset.min30),
    );
    when(() => app.tasks.watchDetails(any())).thenAnswer(
      (_) => app.taskList.stream.map(
        (all) => saved ?? TaskDetails(task: all.first),
      ),
    );
    when(() => app.tasks.update(any())).thenAnswer((i) async {
      saved = i.positionalArguments.single as TaskDetails;
      app.taskList.value = [...app.taskList.value];
    });
  });

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<void> openFromDetail(WidgetTester tester) async {
    await app.pump(tester, location: Routes.task('1'));
    await tapText(tester, 'Reminder');
    expect(find.byType(ReminderSheet), findsOneWidget);
  }

  Future<void> done(WidgetTester tester) async {
    await tester.ensureVisible(find.byType(PrimaryButton).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PrimaryButton).last);
    await tester.pumpAndSettle();
  }

  testWidgets('each option shows when it would fire', (tester) async {
    await openFromDetail(tester);
    expect(
      find.text("Due Thu, 19 Nov · 3:00 PM. You'll be reminded at 2:30 PM."),
      findsOneWidget,
    );
    for (final (option, time) in [
      ('At due time', '3:00 PM'),
      ('10 minutes before', '2:50 PM'),
      ('30 minutes before', '2:30 PM'),
      ('1 hour before', '2:00 PM'),
      ('Morning of', '9:00 AM'),
      ('Day before', 'Wed, 3:00 PM'),
    ]) {
      expect(find.text(option), findsOneWidget, reason: option);
      expect(find.text(time), findsWidgets, reason: time);
    }
  });

  testWidgets('a choice is saved on Done and updates the note', (tester) async {
    await openFromDetail(tester);
    await tapText(tester, 'Day before');
    expect(
      find.text(
        "Due Thu, 19 Nov · 3:00 PM. You'll be reminded on Wed at 3:00 PM.",
      ),
      findsOneWidget,
    );
    await done(tester);
    expect(saved!.task.reminder, ReminderOffset.dayBefore);
    expect(find.text('Day before'), findsOneWidget, reason: 'the row');
  });

  testWidgets('without a time, only Morning of and Day before can fire', (
    tester,
  ) async {
    task(testTask(1, 'Read', dueDate: thursday));
    await openFromDetail(tester);
    expect(find.text('Needs a due time'), findsNWidgets(4));
    await tapText(tester, 'At due time');
    expect(find.text('Due Thu, 19 Nov. No reminder.'), findsOneWidget);
    await tapText(tester, 'Morning of');
    expect(
      find.text("Due Thu, 19 Nov. You'll be reminded at 9:00 AM."),
      findsOneWidget,
    );
  });

  testWidgets('without a date, only No reminder', (tester) async {
    task(testTask(1, 'Someday'));
    await openFromDetail(tester);
    expect(find.text('Set a due date to get a reminder.'), findsOneWidget);
    expect(find.text('Needs a due time'), findsNWidgets(6));
  });

  testWidgets('S11: a new task with a time starts on the default', (
    tester,
  ) async {
    await app.pump(tester, location: Routes.newTask);
    expect(find.text('None'), findsOneWidget, reason: 'no time yet');
    await tapText(tester, 'Due');
    await tapText(tester, 'Tomorrow');
    await tapText(tester, '9:00 AM');
    await done(tester);
    expect(find.text('30 min before'), findsOneWidget);
  });

  testWidgets('S10: the 🔔 button starts on the default for a time', (
    tester,
  ) async {
    await app.pump(tester);
    await tester.tap(find.byTooltip('Quick add task'));
    await tester.pumpAndSettle();
    // Today has no time: the 30-minute default can't fire.
    expect(find.byTooltip('Reminder'), findsOneWidget);
    await tapText(tester, 'Tomorrow · 9 AM');
    expect(find.byTooltip('Reminder · 30 min before'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Call bank');
    await tester.pump();
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
    final draft =
        verify(() => app.tasks.add(captureAny())).captured.single as TaskDraft;
    expect(draft.reminder, ReminderOffset.min30);
  });

  testWidgets('S10: picking on S16 overrides the default', (tester) async {
    await app.pump(tester);
    await tester.tap(find.byTooltip('Quick add task'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Tomorrow · 9 AM');
    await tester.tap(find.byTooltip('Reminder · 30 min before'));
    await tester.pumpAndSettle();
    await tapText(tester, 'No reminder');
    await done(tester);
    expect(find.byTooltip('Reminder'), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('S16 lays out at 200% in ${brightness.name}', (tester) async {
      await app.pump(
        tester,
        location: Routes.task('1'),
        brightness: brightness,
        textScale: 2,
      );
      await tapText(tester, 'Reminder');
      expect(tester.takeException(), isNull);
    });
  }
}
