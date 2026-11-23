import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../projects/presentation/projects_app.dart';

void main() {
  late ProjectsApp app;
  final today = DateTime(2026, 11, 17);

  setUpAll(registerProjectFallbacks);

  setUp(() {
    app = ProjectsApp();
    app.taskList.value = [
      testTask(
        1,
        'Finish Q4 slides',
        dueDate: today,
      ).copyWith(dueMinute: 17 * 60, reminder: ReminderOffset.min30),
      testTask(2, 'Book dentist', dueDate: DateTime(2026, 11, 18)),
    ];
  });

  List<String> titles() => [for (final n in app.scheduler.scheduled) n.title];

  Future<void> settings(
    WidgetTester tester,
    Preferences Function(Preferences) change,
  ) async {
    await app.container.read(preferencesRepositoryProvider).update(change);
    await tester.pumpAndSettle();
  }

  testWidgets('schedules reminders and the daily plan on launch', (
    tester,
  ) async {
    await app.pump(tester);
    final slides = app.scheduler.scheduled.firstWhere(
      (n) => n.title == 'Finish Q4 slides',
    );
    expect(slides.at, DateTime(2026, 11, 17, 16, 30));
    expect(slides.body, 'Today, 5:00 PM');
    // Tomorrow's plan; today's 8 AM has passed.
    final plan = app.scheduler.scheduled.firstWhere(
      (n) => n.title == 'Your plan for today',
    );
    expect(plan.at, DateTime(2026, 11, 18, 8));
    expect(plan.body, '1 task due · first: Book dentist');
    expect(titles(), contains('Weekly review'));
  });

  testWidgets('a task that leaves the open list loses its reminder', (
    tester,
  ) async {
    await app.pump(tester);
    expect(titles(), contains('Finish Q4 slides'));
    // Completed, archived or deleted: it's no longer open.
    app.taskList.value = [
      app.taskList.value.first.copyWith(status: TaskStatus.done),
      app.taskList.value.last,
    ];
    await tester.pumpAndSettle();
    expect(titles(), isNot(contains('Finish Q4 slides')));
  });

  testWidgets('a changed due time moves the reminder', (tester) async {
    await app.pump(tester);
    app.taskList.value = [
      app.taskList.value.first.copyWith(dueMinute: 20 * 60),
      app.taskList.value.last,
    ];
    await tester.pumpAndSettle();
    expect(
      app.scheduler.scheduled
          .firstWhere((n) => n.title == 'Finish Q4 slides')
          .at,
      DateTime(2026, 11, 17, 19, 30),
    );
  });

  testWidgets('turning a type off removes it', (tester) async {
    await app.pump(tester);
    await settings(
      tester,
      (p) => p.copyWith(
        remindersOn: false,
        dailyPlanOn: false,
        weeklyReviewOn: false,
      ),
    );
    expect(app.scheduler.scheduled, isEmpty);
  });

  testWidgets('the overdue nudge follows its toggle', (tester) async {
    app.taskList.value = [
      testTask(3, 'Invoice', dueDate: DateTime(2026, 11, 16)),
    ];
    await app.pump(tester);
    expect(titles(), isNot(contains('1 overdue task')));
    await settings(tester, (p) => p.copyWith(overdueOn: true));
    expect(titles(), contains('1 overdue task'));
  });

  testWidgets('starting focus schedules its end', (tester) async {
    await app.pump(tester, go: Routes.focus);
    await tester.tap(find.byTooltip('Start'));
    await tester.pumpAndSettle();
    final end = app.scheduler.scheduled.firstWhere(
      (n) => n.title == 'Session complete',
    );
    expect(end.at, testNow.add(const Duration(minutes: 25)));
    await tester.tap(find.byTooltip('Pause'));
    await tester.pumpAndSettle();
    expect(titles(), isNot(contains('Session complete')));
  });

  testWidgets('resuming the app plans again from the clock', (tester) async {
    await app.pump(tester);
    expect(titles(), contains('Finish Q4 slides'));
    // Back after the reminder's time.
    app.now = DateTime(2026, 11, 17, 16, 45);
    // Away and back, as the OS reports it.
    [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ].forEach(tester.binding.handleAppLifecycleStateChanged);
    await tester.pumpAndSettle();
    expect(titles(), isNot(contains('Finish Q4 slides')));
  });
}
