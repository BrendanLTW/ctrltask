import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/app_toggle.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/features/notifications/presentation/notification_settings_screen.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../projects/presentation/projects_app.dart';

void main() {
  late ProjectsApp app;

  setUpAll(registerProjectFallbacks);

  setUp(() {
    app = ProjectsApp();
    app.scheduler.permitted = true;
  });

  Future<void> pump(WidgetTester tester, {double textScale = 1}) =>
      app.pump(tester, location: Routes.notifications, textScale: textScale);

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<Preferences> prefs() =>
      app.container.read(preferencesRepositoryProvider).read();

  Future<void> done(WidgetTester tester) async {
    await tester.tap(find.byType(PrimaryButton).last);
    await tester.pumpAndSettle();
  }

  /// Turns the visible wheel to [hour]:[minute].
  Future<void> turnWheel(WidgetTester tester, int hour, int minute) async {
    tester
        .widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker))
        .onDateTimeChanged(DateTime(2000, 1, 1, hour, minute));
    await tester.pump();
  }

  testWidgets('the toggles save, and change what is scheduled', (tester) async {
    await pump(tester);
    expect(find.text('Notifications are off for ctrlTask'), findsNothing);
    expect(
      app.scheduler.scheduled.where((n) => n.title == 'Weekly review'),
      isNotEmpty,
    );
    await tapText(tester, 'Weekly review');
    expect((await prefs()).weeklyReviewOn, isFalse);
    expect(
      app.scheduler.scheduled.where((n) => n.title == 'Weekly review'),
      isEmpty,
    );
    await tapText(tester, 'Overdue nudges');
    expect((await prefs()).overdueOn, isTrue);
  });

  testWidgets('Daily plan at: a time wheel', (tester) async {
    await pump(tester);
    expect(find.text('8:00 AM'), findsOneWidget);
    await tapText(tester, 'Daily plan at');
    await turnWheel(tester, 7, 30);
    await done(tester);
    expect((await prefs()).dailyPlanMinute, 7 * 60 + 30);
    expect(find.text('7:30 AM'), findsOneWidget);
  });

  testWidgets('closing a sheet changes nothing', (tester) async {
    await pump(tester);
    await tapText(tester, 'Daily plan at');
    await turnWheel(tester, 6, 0);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect((await prefs()).dailyPlanMinute, 8 * 60);
  });

  testWidgets('Default task reminder: the S16 options', (tester) async {
    await pump(tester);
    expect(find.text('30 min before'), findsOneWidget);
    await tapText(tester, 'Default task reminder');
    await tapText(tester, '1 hour before');
    await done(tester);
    expect((await prefs()).defaultReminder, ReminderOffset.hour1);
    expect(find.text('1 hour before'), findsOneWidget);
  });

  testWidgets('Quiet hours: change the end, or turn them off', (tester) async {
    await pump(tester);
    expect(find.text('11 PM – 7 AM'), findsOneWidget);
    await tapText(tester, 'Quiet hours');
    await tapText(tester, 'To');
    await turnWheel(tester, 6, 0);
    await done(tester);
    expect(find.text('11 PM – 6 AM'), findsOneWidget);
    final p = await prefs();
    expect((p.quietStartMinute, p.quietEndMinute), (23 * 60, 6 * 60));

    await tapText(tester, 'Quiet hours');
    // The toggle in the sheet, not the row behind it.
    await tester.tap(find.byType(AppToggle).last);
    await tester.pumpAndSettle();
    await done(tester);
    expect(find.text('Off'), findsOneWidget);
    final off = await prefs();
    expect(off.quietStartMinute, off.quietEndMinute);
  });

  group('when the phone blocks notifications', () {
    setUp(() => app.scheduler.permitted = false);

    testWidgets('never asked: Turn on asks, and the box goes', (tester) async {
      await pump(tester);
      expect(find.text('Notifications are off for ctrlTask'), findsOneWidget);
      expect(
        find.text("ctrlTask hasn't asked to send notifications yet."),
        findsOneWidget,
      );
      await tapText(tester, 'Turn on');
      expect(app.scheduler.asked, 1);
      expect((await prefs()).notificationsAsked, isTrue);
      expect(find.text('Notifications are off for ctrlTask'), findsNothing);
    });

    testWidgets('asked before: Open phone settings', (tester) async {
      await pump(tester);
      await app.container
          .read(preferencesRepositoryProvider)
          .update((p) => p.copyWith(notificationsAsked: true));
      await tester.pumpAndSettle();
      await tapText(tester, 'Open phone settings');
      expect(app.scheduler.openedSettings, 1);
    });

    testWidgets('the toggles still save', (tester) async {
      await pump(tester);
      await tapText(tester, 'Daily plan');
      expect((await prefs()).dailyPlanOn, isFalse);
    });

    testWidgets('back from Settings, it checks again', (tester) async {
      await pump(tester);
      app.scheduler.permitted = true;
      [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ].forEach(tester.binding.handleAppLifecycleStateChanged);
      await tester.pumpAndSettle();
      expect(find.text('Notifications are off for ctrlTask'), findsNothing);
    });
  });

  testWidgets('opens from Settings, which counts what is on', (tester) async {
    await app.pump(tester, location: Routes.settings);
    expect(find.text('4 on'), findsOneWidget);
    await tapText(tester, 'Notifications');
    expect(find.byType(NotificationSettingsScreen), findsOneWidget);
  });

  test('notificationsOn counts the five toggles', () {
    expect(notificationsOn(const Preferences()), 4);
    expect(
      notificationsOn(
        const Preferences(
          remindersOn: false,
          dailyPlanOn: false,
          focusEndOn: false,
          weeklyReviewOn: false,
        ),
      ),
      0,
    );
  });

  for (final brightness in Brightness.values) {
    testWidgets('S39 lays out at 200% in ${brightness.name}', (tester) async {
      app.scheduler.permitted = false;
      await app.pump(
        tester,
        location: Routes.notifications,
        brightness: brightness,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      // Far down the list with large text.
      await tester.scrollUntilVisible(
        find.text('Quiet hours'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tapText(tester, 'Quiet hours');
      expect(tester.takeException(), isNull);
    });
  }
}
