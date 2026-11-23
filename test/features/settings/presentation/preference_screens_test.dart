import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/settings/presentation/preferences/preference_screens.dart';
import 'package:ctrltask/features/settings/presentation/preferences/theme_screen.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../projects/presentation/projects_app.dart';

void main() {
  late ProjectsApp app;

  setUpAll(registerProjectFallbacks);

  setUp(() => app = ProjectsApp());

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<Preferences> prefs() =>
      app.container.read(preferencesRepositoryProvider).read();

  group('S36 Theme', () {
    testWidgets('picking one saves it and switches the app', (tester) async {
      await app.pump(tester, location: Routes.theme);
      expect(
        find.text(
          "System follows your phone's setting and switches automatically at "
          'night.',
        ),
        findsOneWidget,
      );
      await tapText(tester, 'Dark');
      expect((await prefs()).theme, AppTheme.dark);
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark,
      );
      expect(
        Theme.of(tester.element(find.byType(ThemeScreen))).brightness,
        Brightness.dark,
      );
      await tapText(tester, 'Light');
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.light,
      );
    });
  });

  group('S37 Week starts on', () {
    testWidgets('saves, and This week in Tasks follows', (tester) async {
      // Sun 22 Nov: this week from Monday, next week from Sunday.
      app.taskList.value = [
        testTask(1, 'Plan', dueDate: DateTime(2026, 11, 22)),
      ];
      await app.pump(tester, location: Routes.weekStart);
      for (final text in ['Monday', 'Common in Malaysia and Europe']) {
        expect(find.text(text), findsOneWidget);
      }
      await tapText(tester, 'Sunday');
      expect((await prefs()).weekStart, WeekStart.sun);

      app.router.go(Routes.tasks);
      await tester.pumpAndSettle();
      expect(find.text('LATER'), findsOneWidget);
      expect(find.text('THIS WEEK'), findsNothing);

      app.router.push(Routes.weekStart).ignore();
      await tester.pumpAndSettle();
      await tapText(tester, 'Monday');
      app.router.go(Routes.tasks);
      await tester.pumpAndSettle();
      expect(find.text('THIS WEEK'), findsOneWidget);
    });
  });

  group('S38 Default priority', () {
    testWidgets('saves, and quick add starts there', (tester) async {
      await app.pump(tester, location: Routes.defaultPriority);
      expect(find.text('Red ring, always shows a tag'), findsOneWidget);
      await tapText(tester, 'High');
      expect((await prefs()).defaultPriority, TaskPriority.high);

      app.router.go(Routes.home);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Quick add task'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AppChip>(
              find.byWidgetPredicate((w) => w is AppChip && w.label == 'High'),
            )
            .selected,
        isTrue,
      );
    });
  });

  testWidgets('S35 shows each value and opens each screen', (tester) async {
    await app.pump(tester);
    await app.container
        .read(preferencesRepositoryProvider)
        .update((p) => p.copyWith(weekStart: WeekStart.sat));
    app.router.push(Routes.settings).ignore();
    await tester.pumpAndSettle();
    for (final text in ['System', 'Saturday', 'Medium']) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    for (final (row, screen) in [
      ('Theme', ThemeScreen),
      ('Week starts on', WeekStartScreen),
      ('Default priority', DefaultPriorityScreen),
    ]) {
      await tapText(tester, row);
      expect(find.byType(screen), findsOneWidget, reason: row);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
    }
  });

  for (final brightness in Brightness.values) {
    testWidgets('S36–S38 lay out at 200% in ${brightness.name}', (
      tester,
    ) async {
      await app.pump(tester, brightness: brightness, textScale: 2);
      for (final route in [
        Routes.theme,
        Routes.weekStart,
        Routes.defaultPriority,
      ]) {
        app.router.push(route).ignore();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: route);
        app.router.pop();
        await tester.pumpAndSettle();
      }
    });
  }
}
