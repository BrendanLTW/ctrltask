import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/app_stepper.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_timer.dart';
import 'package:ctrltask/features/focus/presentation/timer_settings_sheet.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../projects/presentation/projects_app.dart';

void main() {
  late ProjectsApp app;

  setUpAll(registerProjectFallbacks);

  setUp(() {
    app = ProjectsApp();
    app.active.value = [
      testProject(2, 'Q4 report', color: ProjectColorKey.orange),
    ];
    app.taskList.value = [testTask(1, 'Q4 revenue slides', projectId: 2)];
  });

  /// Focus, with [change] applied to the settings first.
  Future<void> pump(
    WidgetTester tester, {
    Preferences Function(Preferences)? change,
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) async {
    await app.pump(tester, brightness: brightness, textScale: textScale);
    if (change != null) {
      await app.container.read(preferencesRepositoryProvider).update(change);
    }
    app.router.go(Routes.focus);
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String tooltip) async {
    await tester.tap(find.byTooltip(tooltip));
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<void> wait(WidgetTester tester, Duration duration) async {
    app.now = app.now.add(duration);
    await tester.pump(duration);
    await tester.pumpAndSettle();
  }

  FocusTimer saved() => app.timers.value!;

  Preferences manualBreaks(Preferences p) => p.copyWith(autoStartBreaks: false);

  /// Runs a linked 25-minute session to its end.
  Future<void> runSession(WidgetTester tester, {bool linked = true}) async {
    if (linked) {
      await tapText(tester, 'Change');
      await tapText(tester, 'Q4 revenue slides');
    }
    await tap(tester, 'Start');
    await wait(tester, const Duration(minutes: 25));
  }

  group('S32 Session complete', () {
    testWidgets('shows what was done and the round', (tester) async {
      await pump(tester, change: manualBreaks);
      await runSession(tester);
      expect(saved().phase, TimerPhase.done);
      for (final text in [
        'Session complete',
        '25 min on Q4 revenue slides',
        'Start 5-min break',
        'Skip break',
        'Mark task done',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(find.textContaining('3 more for a long break'), findsOneWidget);
      expect(find.text('Short · 5'), findsNothing, reason: 'no segments');
    });

    testWidgets('Start break runs the break', (tester) async {
      await pump(tester, change: manualBreaks);
      await runSession(tester);
      await tapText(tester, 'Start 5-min break');
      expect(
        (saved().kind, saved().phase),
        (FocusKind.short, TimerPhase.running),
      );
      await tap(tester, 'Pause');
    });

    testWidgets('Skip break readies the next session', (tester) async {
      await pump(tester, change: manualBreaks);
      await runSession(tester);
      await tapText(tester, 'Skip break');
      expect((saved().kind, saved().phase), (FocusKind.focus, TimerPhase.idle));
      expect(find.text('Session 2 of 4'), findsOneWidget);
    });

    testWidgets('Mark task done completes it and hides itself', (tester) async {
      await pump(tester, change: manualBreaks);
      await runSession(tester);
      await tapText(tester, 'Mark task done');
      verify(() => app.tasks.complete(1)).called(1);
      expect(find.text('Nice. “Q4 revenue slides” is done'), findsOneWidget);
      expect(find.text('Mark task done'), findsNothing);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('without a task: minutes of focus, nothing to mark', (
      tester,
    ) async {
      await pump(tester, change: manualBreaks);
      await runSession(tester, linked: false);
      expect(find.text('25 min of focus'), findsOneWidget);
      expect(find.text('Mark task done'), findsNothing);
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
      await pump(tester, change: manualBreaks);
      await runSession(tester);
      expect(find.text('Start 15-min break'), findsOneWidget);
      expect(find.textContaining('long break next'), findsOneWidget);
    });
  });

  group('S33 breaks', () {
    Future<void> onBreak(WidgetTester tester, {bool autoNext = false}) async {
      await pump(tester, change: (p) => p.copyWith(autoStartNext: autoNext));
      await runSession(tester);
      expect(saved().kind, FocusKind.short, reason: 'started by itself');
    }

    testWidgets('Finish ends the break and starts focusing', (tester) async {
      await onBreak(tester);
      await wait(tester, const Duration(minutes: 2));
      await tap(tester, 'Finish session');
      expect(app.sessions.value.last.kind, FocusKind.short);
      expect(
        (saved().kind, saved().phase),
        (FocusKind.focus, TimerPhase.running),
      );
      await tap(tester, 'Pause');
    });

    testWidgets('a break that runs out reads Break over until Play', (
      tester,
    ) async {
      await onBreak(tester);
      await wait(tester, const Duration(minutes: 5));
      expect(find.text('BREAK OVER'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);
      await tap(tester, 'Start focusing');
      expect(
        (saved().kind, saved().phase),
        (FocusKind.focus, TimerPhase.running),
      );
      await tap(tester, 'Pause');
    });

    testWidgets('with Start next automatically, focus follows at once', (
      tester,
    ) async {
      await onBreak(tester, autoNext: true);
      await wait(tester, const Duration(minutes: 5));
      expect(
        (saved().kind, saved().phase),
        (FocusKind.focus, TimerPhase.running),
      );
      await tap(tester, 'Pause');
    });
  });

  group('S31 Timer settings', () {
    Finder stepper(String title) => find.byWidgetPredicate(
      (w) => w is AppStepper && w.semanticLabel == title,
    );

    testWidgets('Save as default applies the new lengths', (tester) async {
      await pump(tester);
      await tap(tester, 'Timer settings');
      expect(find.byType(TimerSettingsSheet), findsOneWidget);
      tester.widget<AppStepper>(stepper('Focus')).onIncrement!();
      await tester.pump();
      expect(find.text('30 min'), findsOneWidget);
      await tapText(tester, 'Start breaks automatically');
      await tapText(tester, 'Save as default');

      final prefs = await app.container
          .read(preferencesRepositoryProvider)
          .read();
      expect((prefs.focusMin, prefs.autoStartBreaks), (30, false));
      expect(find.text('Focus · 30'), findsOneWidget);
      expect(find.text('30:00'), findsOneWidget, reason: 'idle follows');
    });

    testWidgets('closing discards the changes', (tester) async {
      await pump(tester);
      await tap(tester, 'Timer settings');
      tester.widget<AppStepper>(stepper('Focus')).onIncrement!();
      await tester.pump();
      await tap(tester, 'Close');
      final prefs = await app.container
          .read(preferencesRepositoryProvider)
          .read();
      expect(prefs.focusMin, 25);
    });

    testWidgets('steppers stop at their limits', (tester) async {
      await pump(tester, change: (p) => p.copyWith(focusMin: 90, shortMin: 1));
      await tap(tester, 'Timer settings');
      expect(tester.widget<AppStepper>(stepper('Focus')).onIncrement, isNull);
      expect(
        tester.widget<AppStepper>(stepper('Short break')).onDecrement,
        isNull,
      );
    });

    testWidgets('opens from Settings → Default focus length', (tester) async {
      await pump(tester);
      app.router.push(Routes.settings).ignore();
      await tester.pumpAndSettle();
      await tapText(tester, 'Default focus length');
      expect(find.byType(TimerSettingsSheet), findsOneWidget);
    });
  });

  for (final brightness in Brightness.values) {
    testWidgets('S31, S32 and S33 lay out at 200% in ${brightness.name}', (
      tester,
    ) async {
      await pump(
        tester,
        change: manualBreaks,
        brightness: brightness,
        textScale: 2,
      );
      await tap(tester, 'Start');
      await wait(tester, const Duration(minutes: 25));
      expect(tester.takeException(), isNull, reason: 'S32');
      await tapText(tester, 'Start 5-min break');
      expect(tester.takeException(), isNull, reason: 'S33');
      await tap(tester, 'Pause');
      await tap(tester, 'Timer settings');
      expect(tester.takeException(), isNull, reason: 'S31');
    });
  }
}
