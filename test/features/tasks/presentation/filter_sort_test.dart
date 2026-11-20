import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/task_list.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/features/tasks/presentation/list/filter_sort_sheet.dart';
import 'package:ctrltask/features/tasks/presentation/tasks_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../projects/presentation/projects_app.dart';

void main() {
  late ProjectsApp app;
  final today = DateTime(2026, 11, 17);

  setUpAll(registerProjectFallbacks);

  setUp(() {
    app = ProjectsApp();
    app.active.value = [
      testProject(1, 'Website redesign'),
      testProject(2, 'Q4 report', color: ProjectColorKey.orange),
    ];
    app.taskList.value = [
      testTask(
        1,
        'Slides',
        projectId: 2,
        dueDate: today,
      ).copyWith(priority: TaskPriority.urgent),
      testTask(
        2,
        'Wireframes',
        projectId: 1,
        dueDate: today,
      ).copyWith(priority: TaskPriority.high),
      testTask(3, 'Call', dueDate: DateTime(2026, 11, 20)),
      testTask(4, 'Old copy', projectId: 1, done: true),
    ];
  });

  Future<void> pump(WidgetTester tester) async {
    await app.pump(tester, go: Routes.tasks);
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.byTooltip(RegExp('^Filter and sort')));
    await tester.pumpAndSettle();
    expect(find.byType(FilterSortSheet), findsOneWidget);
  }

  /// Taps a chip in the sheet, not one behind it.
  Future<void> tapChip(WidgetTester tester, String label) async {
    final chip = find.descendant(
      of: find.byType(FilterSortSheet),
      matching: find.widgetWithText(AppChip, label),
    );
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();
  }

  Future<void> show(WidgetTester tester) async {
    final button = find.textContaining(RegExp(r'^Show \d'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  ListOptions options() => app.container.read(taskListOptionsProvider);

  testWidgets('a dot shows once anything differs from the defaults', (
    tester,
  ) async {
    await pump(tester);
    expect(find.byTooltip('Filter and sort'), findsOneWidget);
    await openSheet(tester);
    await tapText(tester, 'Priority');
    await show(tester);
    expect(find.byTooltip('Filter and sort, filters on'), findsOneWidget);
  });

  testWidgets('Sort by Priority groups the list', (tester) async {
    await pump(tester);
    await openSheet(tester);
    await tapText(tester, 'Priority');
    await show(tester);
    expect(options().sort, TaskSort.priority);
    for (final header in ['URGENT', 'HIGH', 'MEDIUM']) {
      expect(find.text(header), findsOneWidget, reason: header);
    }
    expect(find.text('TODAY · TUE 17'), findsNothing);
  });

  testWidgets('Sort by Project groups by project, Inbox last', (tester) async {
    await pump(tester);
    await openSheet(tester);
    await tapText(tester, 'Project');
    await show(tester);
    final headers = [
      for (final h in ['WEBSITE REDESIGN', 'Q4 REPORT', 'INBOX'])
        tester.getTopLeft(find.text(h)).dy,
    ];
    expect(headers, [...headers]..sort());
  });

  testWidgets('Sort by Date added is one list', (tester) async {
    await pump(tester);
    await openSheet(tester);
    await tapText(tester, 'Date added');
    await show(tester);
    expect(find.text('NEWEST FIRST'), findsOneWidget);
  });

  testWidgets('priority and project chips narrow the list and counts', (
    tester,
  ) async {
    await pump(tester);
    await openSheet(tester);
    await tapChip(tester, 'High');
    await tapChip(tester, 'Urgent');
    expect(find.text('Show 2 tasks'), findsOneWidget);
    await tapChip(tester, 'Q4 report');
    expect(find.text('Show 1 task'), findsOneWidget);
    await show(tester);
    expect(find.text('Slides'), findsOneWidget);
    expect(find.text('Wireframes'), findsNothing);
    expect(find.text('Call'), findsNothing);
  });

  testWidgets('filters combine with the chip', (tester) async {
    await pump(tester);
    await tapText(tester, 'Upcoming');
    await openSheet(tester);
    await tapChip(tester, 'Urgent');
    // Upcoming has no urgent task.
    expect(find.text('Show 0 tasks'), findsOneWidget);
  });

  testWidgets('Show completed adds a Completed section', (tester) async {
    await pump(tester);
    await openSheet(tester);
    await tapText(tester, 'Show completed tasks');
    await show(tester);
    expect(find.text('COMPLETED'), findsOneWidget);
    expect(find.text('Old copy'), findsOneWidget);
  });

  testWidgets('Reset clears the sheet only; the chip stays', (tester) async {
    await pump(tester);
    await tapText(tester, 'Today');
    await openSheet(tester);
    await tapChip(tester, 'High');
    await tapText(tester, 'Priority');
    await show(tester);
    await openSheet(tester);
    await tapText(tester, 'Reset');
    await show(tester);
    expect(options(), defaultListOptions);
    expect(app.container.read(tasksFilterProvider), TaskFilter.today);
  });

  testWidgets('closing without Show changes nothing', (tester) async {
    await pump(tester);
    await openSheet(tester);
    await tapText(tester, 'Priority');
    await tester.tapAt(const Offset(195, 20));
    await tester.pumpAndSettle();
    expect(options(), defaultListOptions);
  });

  for (final brightness in Brightness.values) {
    testWidgets('S23 lays out at 200% in ${brightness.name}', (tester) async {
      await app.pump(
        tester,
        go: Routes.tasks,
        brightness: brightness,
        textScale: 2,
      );
      await openSheet(tester);
      expect(tester.takeException(), isNull);
    });
  }
}
