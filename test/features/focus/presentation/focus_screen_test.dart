import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_timer.dart';
import 'package:ctrltask/features/focus/presentation/focus_screen.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../projects/presentation/projects_app.dart';

void main() {
  late ProjectsApp app;

  setUpAll(() {
    registerProjectFallbacks();
    registerFallbackValue(TaskDetails(task: testTask(0, '')));
  });

  setUp(() {
    app = ProjectsApp();
    app.active.value = [
      testProject(2, 'Q4 report', color: ProjectColorKey.orange),
    ];
    app.taskList.value = [
      testTask(1, 'Finish Q4 revenue slides', projectId: 2, dueDate: today),
      testTask(2, 'Call contractor', dueDate: today),
    ];
    when(() => app.tasks.watchDetails(any())).thenAnswer((i) {
      final id = i.positionalArguments.single as int;
      return Stream.value(
        TaskDetails(task: app.taskList.value.firstWhere((t) => t.id == id)),
      );
    });
  });

  Future<void> pump(WidgetTester tester) => app.pump(tester, go: Routes.focus);

  Future<void> tap(WidgetTester tester, String tooltip) async {
    await tester.tap(find.byTooltip(tooltip));
    await tester.pumpAndSettle();
  }

  /// Moves the clock and lets timers due by then fire.
  Future<void> wait(WidgetTester tester, Duration duration) async {
    app.now = app.now.add(duration);
    await tester.pump(duration);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  FocusTimer saved() => app.timers.value!;

  testWidgets('idle: the full length, session 1, and Start', (tester) async {
    await pump(tester);
    for (final text in [
      'Focus · 25',
      'Short · 5',
      'Long · 15',
      'READY',
      '25:00',
      'Session 1 of 4',
      'No task',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.byTooltip('Start'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byTooltip('Reset'),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('runs from the clock, pauses and resumes', (tester) async {
    await pump(tester);
    await tap(tester, 'Start');
    expect(find.text('FOCUSING'), findsOneWidget);

    await wait(tester, const Duration(seconds: 90));
    expect(find.text('23:30'), findsOneWidget);

    await tap(tester, 'Pause');
    expect(find.text('PAUSED'), findsOneWidget);
    await wait(tester, const Duration(minutes: 5));
    expect(find.text('23:30'), findsOneWidget, reason: 'stands still');

    await tap(tester, 'Resume');
    await wait(tester, const Duration(seconds: 30));
    expect(find.text('23:00'), findsOneWidget);
    await tap(tester, 'Pause');
  });

  testWidgets('Finish saves the session and readies a short break', (
    tester,
  ) async {
    await pump(tester);
    await tapText(tester, 'Change');
    await tapText(tester, 'Finish Q4 revenue slides');
    await tap(tester, 'Start');
    await wait(tester, const Duration(minutes: 10));
    await tap(tester, 'Finish session');

    final session = app.sessions.value.single;
    expect(
      (session.kind, session.elapsedSec, session.taskId, session.completed),
      (FocusKind.focus, 600, 1, false),
    );
    // Breaks start by themselves by default (S31).
    expect(
      (saved().kind, saved().phase, saved().taskId),
      (FocusKind.short, TimerPhase.running, 1),
    );
    expect(find.text('ON A BREAK'), findsOneWidget);
    expect(find.text('Next: session 2 of 4'), findsOneWidget);
    expect(find.text(breakTip), findsOneWidget);
    await tap(tester, 'Pause');
  });

  testWidgets('a session that runs out saves itself as completed', (
    tester,
  ) async {
    await pump(tester);
    await tap(tester, 'Start');
    await wait(tester, const Duration(minutes: 25));
    final session = app.sessions.value.single;
    expect((session.elapsedSec, session.completed), (1500, true));
    expect(saved().kind, FocusKind.short);
    await tap(tester, 'Pause');
  });

  testWidgets('after a full round the break is long', (tester) async {
    app.sessions.value = [
      for (var i = 0; i < 3; i++)
        FocusSession(
          id: i,
          kind: FocusKind.focus,
          plannedSec: 1500,
          startedAt: testNow.toUtc(),
          elapsedSec: 1500,
          completed: true,
        ),
    ];
    await pump(tester);
    expect(find.text('Session 4 of 4'), findsOneWidget);
    await tap(tester, 'Start');
    await wait(tester, const Duration(minutes: 25));
    expect(saved().kind, FocusKind.long);
    expect(find.text('15:00'), findsOneWidget, reason: 'just started');
    await tap(tester, 'Pause');
  });

  testWidgets('reopened after it ran out, it saves at full length', (
    tester,
  ) async {
    // Started an hour ago, then the app was killed.
    app.timers.value = FocusTimer(
      phase: TimerPhase.running,
      startedAt: testNow.subtract(const Duration(hours: 1)).toUtc(),
      runningSince: testNow.subtract(const Duration(hours: 1)).toUtc(),
    );
    await pump(tester);
    final session = app.sessions.value.single;
    expect((session.elapsedSec, session.completed), (1500, true));
    expect(saved().kind, FocusKind.short);
    await tap(tester, 'Pause');
  });

  testWidgets('back from the background after it ran out, it finishes', (
    tester,
  ) async {
    await pump(tester);
    await tap(tester, 'Start');
    // The phone sleeps: the clock moves on but the app's timers don't.
    app.now = app.now.add(const Duration(minutes: 30));
    expect(app.sessions.value, isEmpty);
    [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ].forEach(tester.binding.handleAppLifecycleStateChanged);
    await tester.pump();
    final session = app.sessions.value.single;
    expect((session.elapsedSec, session.completed), (1500, true));
    expect(saved().kind, FocusKind.short);
    await tap(tester, 'Pause');
  });

  testWidgets('Reset starts the session over and saves nothing', (
    tester,
  ) async {
    await pump(tester);
    await tap(tester, 'Start');
    await wait(tester, const Duration(minutes: 3));
    await tap(tester, 'Reset');
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('READY'), findsOneWidget);
    expect(app.sessions.value, isEmpty);
  });

  testWidgets('switching mode mid-session saves what ran', (tester) async {
    await pump(tester);
    await tap(tester, 'Start');
    await wait(tester, const Duration(minutes: 4));
    await tapText(tester, 'Long · 15');
    expect(app.sessions.value.single.elapsedSec, 240);
    expect(find.text('15:00'), findsOneWidget);
  });

  testWidgets('Change links a task, or No task', (tester) async {
    await pump(tester);
    await tapText(tester, 'Change');
    // Today's tasks, and No task ticked.
    expect(find.text('Call contractor'), findsOneWidget);
    await tapText(tester, 'Call contractor');
    expect(saved().taskId, 2);
    expect(find.text('Call contractor'), findsOneWidget);

    await tapText(tester, 'Change');
    await tapText(tester, 'No task');
    expect(saved().taskId, isNull);
  });

  testWidgets('screen readers hear phase changes, not every second', (
    tester,
  ) async {
    final heard = <String>[];
    tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
      SystemChannels.accessibility,
      (message) async {
        final data = (message as Map)['data'] as Map;
        if (data['message'] case final String text) heard.add(text);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<dynamic>(
            SystemChannels.accessibility,
            null,
          ),
    );
    await pump(tester);
    await tap(tester, 'Start');
    await wait(tester, const Duration(seconds: 5));
    await tap(tester, 'Pause');
    expect(heard, ['Focusing', 'Paused']);
  });

  group('S12 Start a focus session', () {
    testWidgets('links the task and opens Focus', (tester) async {
      await app.pump(tester, location: Routes.task('1'));
      await tester.scrollUntilVisible(
        find.text('Start a focus session'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tapText(tester, 'Start a focus session');
      expect(find.byType(FocusScreen), findsOneWidget);
      expect(saved().taskId, 1);
      expect(find.text('Finish Q4 revenue slides'), findsOneWidget);
    });

    testWidgets('keeps the task of a session under way', (tester) async {
      app.timers.value = FocusTimer(
        taskId: 2,
        phase: TimerPhase.paused,
        startedAt: testNow.toUtc(),
        bankedSec: 60,
      );
      await app.pump(tester, location: Routes.task('1'));
      await tester.scrollUntilVisible(
        find.text('Start a focus session'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tapText(tester, 'Start a focus session');
      expect(find.byType(FocusScreen), findsOneWidget);
      expect(saved().taskId, 2);
    });
  });

  for (final brightness in Brightness.values) {
    testWidgets('lays out at 200% text in ${brightness.name}', (tester) async {
      await app.pump(
        tester,
        go: Routes.focus,
        brightness: brightness,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  }
}

final today = DateTime(2026, 11, 17);

const breakTip = 'Stand up, refill your water and look at something far away.';
