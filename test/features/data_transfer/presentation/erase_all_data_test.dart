import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/features/data_transfer/presentation/export_screen.dart';
import 'package:ctrltask/features/onboarding/presentation/welcome_screen.dart';
import 'package:ctrltask/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../projects/presentation/projects_app.dart';

void main() {
  late ProjectsApp app;

  setUpAll(registerProjectFallbacks);

  setUp(() {
    app = ProjectsApp();
    app.active.value = [testProject(1, 'Website')];
    app.archived.value = [testProject(2, 'Old site')];
    app.taskList.value = [
      testTask(1, 'Plan', projectId: 1),
      testTask(2, 'Ship', projectId: 2, done: true),
      testTask(3, 'Call'),
    ];
  });

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester) async {
    await app.pump(tester, location: Routes.settings);
    await tapText(tester, 'Erase all data');
  }

  testWidgets('S44 counts everything, archived projects too', (tester) async {
    await open(tester);
    expect(find.text('Erase all data?'), findsOneWidget);
    expect(
      find.text(
        'This deletes 3 tasks, 2 projects and all focus history from this '
        "phone. It can't be undone.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('Cancel changes nothing', (tester) async {
    await open(tester);
    await tapText(tester, 'Cancel');
    expect(find.text('Erase all data?'), findsNothing);
    expect(app.eraser.erased, 0);
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('Export a copy first opens S41 without erasing', (tester) async {
    await open(tester);
    await tapText(tester, 'Export a copy first');
    expect(find.byType(ExportScreen), findsOneWidget);
    expect(app.eraser.erased, 0);
  });

  testWidgets('Erase everything erases, cancels and starts over', (
    tester,
  ) async {
    await open(tester);
    app.scheduler.scheduled.add((
      id: 1,
      at: DateTime(2026, 11, 18, 8),
      title: 'Plan your day',
      body: '',
    ));
    await tapText(tester, 'Erase everything');
    expect(app.eraser.erased, 1);
    expect(app.scheduler.scheduled, isEmpty);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('S44 lays out at 200% in ${brightness.name}', (tester) async {
      await app.pump(
        tester,
        location: Routes.settings,
        brightness: brightness,
        textScale: 2,
      );
      await tester.scrollUntilVisible(
        find.text('Erase all data'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tapText(tester, 'Erase all data');
      expect(tester.takeException(), isNull);
      expect(find.text('Erase everything'), findsOneWidget);
    });
  }
}
