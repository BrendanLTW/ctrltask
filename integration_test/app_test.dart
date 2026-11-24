import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/widgets/app_shell_tab.dart';
import 'package:ctrltask/features/notifications/domain/notification_scheduler.dart';
import 'package:ctrltask/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// The end-to-end path (CLAUDE.md Testing, PLAN 4.4) on a device or
/// simulator: `flutter test integration_test/app_test.dart -d <device>`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding → quick add → complete → undo → a focus session', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    // Type through Flutter, not the device keyboard.
    tester.testTextInput.register();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    // A clock the test moves, as a phone left for half an hour would.
    var now = DateTime(2026, 11, 17, 9, 41);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...appOverrides(),
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          notificationSchedulerProvider.overrideWithValue(_NoNotifications()),
        ],
        child: const MainApp(),
      ),
    );
    Future<void> settle() => tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 15),
    );
    await settle();

    // On a device typing doesn't rebuild by itself: settle before tapping.
    Future<void> type(String text) async {
      await tester.enterText(find.byType(EditableText).last, text);
      await settle();
    }

    Future<void> tapText(String text) async {
      await tester.tap(find.text(text).last);
      await settle();
    }

    // Onboarding: S02 → S03 → S04 → S05 → S06 → Home.
    await tapText('Get started');
    await type('Alex');
    await tapText('Continue');
    await type('Water the plants');
    await tapText('Add task');
    await tapText('Not now');
    expect(find.text("You're all set, Alex"), findsOneWidget);
    await tapText('Go to Today');
    expect(find.text('Good morning, Alex'), findsOneWidget);
    expect(find.text('Water the plants'), findsOneWidget);

    // Quick add, due today.
    await tester.tap(find.byTooltip('Quick add task'));
    await settle();
    await type('Call the dentist');
    await tester.tap(find.byTooltip('Add task'));
    await settle();
    expect(find.text('Call the dentist'), findsOneWidget);

    // Complete it, then Undo.
    await tester.tap(find.bySemanticsLabel('Complete: Call the dentist'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Undo'), findsOneWidget);
    expect(find.bySemanticsLabel('Complete: Call the dentist'), findsNothing);
    await tester.tap(find.text('Undo'));
    await settle();
    expect(find.bySemanticsLabel('Complete: Call the dentist'), findsOneWidget);

    // A focus session: start, leave the app for half an hour, come back.
    await tester.tap(
      find.byWidgetPredicate((w) => w is AppShellTab && w.label == 'Focus'),
    );
    await settle();
    await tester.tap(find.byTooltip('Start'));
    // A running timer redraws every second, so it never settles.
    await tester.pump(const Duration(seconds: 1));
    now = now.add(const Duration(minutes: 30));
    [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ].forEach(tester.binding.handleAppLifecycleStateChanged);
    await tester.pump(const Duration(seconds: 1));
    // Saved, and with breaks starting automatically (the default) the
    // short break is already running.
    expect(find.text('ON A BREAK'), findsOneWidget);
    expect(find.text('Next: session 2 of 4'), findsOneWidget);
    // Paused, or the ticking break would keep the app from settling.
    await tester.tap(find.byTooltip('Pause'));
    await settle();

    // Home counts the 25 minutes.
    await tester.tap(
      find.byWidgetPredicate((w) => w is AppShellTab && w.label == 'Home'),
    );
    await settle();
    // The stat tile's own label: tiles merge into their row for readers.
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Focused today, 25m',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });
}

/// No permission prompt and nothing scheduled on the simulator.
class _NoNotifications implements NotificationScheduler {
  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<bool> isPermitted() async => false;

  @override
  Future<void> openSystemSettings() async {}

  @override
  Future<void> scheduleOnce({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancelAll() async {}
}
