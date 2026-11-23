import 'dart:convert';

import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/month_calendar.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/features/data_transfer/domain/export_data.dart';
import 'package:ctrltask/features/data_transfer/presentation/export_screen.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../projects/presentation/projects_app.dart';

void main() {
  late ProjectsApp app;

  setUpAll(registerProjectFallbacks);

  Project project(int id, {bool archived = false}) => Project(
    id: id,
    name: 'Project $id',
    colorKey: ProjectColorKey.blue,
    iconKey: ProjectIconKey.globe,
    createdAt: DateTime.utc(2026),
    sortOrder: id,
    archivedAt: archived ? DateTime.utc(2026, 11) : null,
  );

  ExportTask entry(
    int id, {
    required DateTime created,
    bool done = false,
    Project? p,
  }) => (
    task: Task(
      id: id,
      title: 'Task $id',
      priority: TaskPriority.medium,
      status: done ? TaskStatus.done : TaskStatus.open,
      boardColumn: done ? BoardColumn.done : BoardColumn.todo,
      createdAt: created.toUtc(),
      updatedAt: DateTime.utc(2026),
      sortOrder: id,
      projectId: p?.id,
      completedAt: done ? DateTime.utc(2026, 11, 3) : null,
    ),
    project: p,
    tags: const [],
    repeat: null,
  );

  setUp(() {
    app = ProjectsApp();
    final active = project(1);
    final archived = project(2, archived: true);
    app.exportSource.snapshot = ExportSnapshot(
      schemaVersion: 1,
      tables: {
        'projects': [
          {'id': 1},
          {'id': 2},
        ],
        'tasks': [
          for (final id in [1, 2, 3, 4]) {'id': id},
        ],
        'focus_sessions': [
          {'id': 1, 'taskId': null},
        ],
        'preferences': [
          {'key': 'name', 'value': 'Alex'},
        ],
      },
      projects: [active, archived],
      tasks: [
        entry(1, created: DateTime(2026, 11, 10), p: active),
        entry(2, created: DateTime(2026, 11, 2), done: true),
        entry(3, created: DateTime(2026, 11, 5), p: archived),
        entry(4, created: DateTime(2025, 10, 2)),
      ],
      sessions: [
        FocusSession(
          id: 1,
          kind: FocusKind.focus,
          plannedSec: 1500,
          startedAt: DateTime.utc(2026, 11, 16, 9),
          elapsedSec: 1500,
        ),
      ],
    );
  });

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<void> export(WidgetTester tester) async {
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
  }

  testWidgets('S41 exports CSV with the defaults', (tester) async {
    await app.pump(tester, location: Routes.export);
    // Archived projects are off; CSV holds tasks only.
    expect(find.text('3 tasks · 1 project'), findsOneWidget);
    expect(find.text('Export CSV · 1 KB'), findsOneWidget);
    await export(tester);
    final file = app.sharer.shared.single;
    expect(file.fileName, 'ctrltask-2026-11-17.csv');
    expect(file.mimeType, 'text/csv');
    expect(file.contents, startsWith(csvHeader.join(',')));
    expect(file.contents, contains('Task 1,open,medium,,,Project 1'));
    expect(file.contents, isNot(contains('Task 3')));
  });

  testWidgets('JSON counts focus sessions and exports every table', (
    tester,
  ) async {
    await app.pump(tester, location: Routes.export);
    await tapText(tester, 'JSON');
    expect(find.text('3 tasks · 1 project · 1 focus session'), findsOneWidget);
    expect(find.textContaining('Export JSON · '), findsOneWidget);
    await export(tester);
    final file = app.sharer.shared.single;
    expect(file.fileName, 'ctrltask-2026-11-17.json');
    expect(file.mimeType, 'application/json');
    final json = jsonDecode(file.contents) as Map<String, Object?>;
    expect(json['schemaVersion'], 1);
    expect(json['exportedAt'], isA<String>());
    final tables = json['tables']! as Map<String, Object?>;
    expect(tables['tasks'], [
      {'id': 1},
      {'id': 2},
      {'id': 4},
    ]);
    expect(tables['preferences'], hasLength(1));
  });

  testWidgets('the Include toggles change the totals', (tester) async {
    await app.pump(tester, location: Routes.export);
    await tapText(tester, 'Archived projects');
    expect(find.text('4 tasks · 2 projects'), findsOneWidget);
    await tapText(tester, 'Completed tasks');
    expect(find.text('3 tasks · 2 projects'), findsOneWidget);
    await tapText(tester, 'JSON');
    await tapText(tester, 'Focus sessions');
    expect(
      find.text('3 tasks · 2 projects · 0 focus sessions'),
      findsOneWidget,
    );
  });

  testWidgets('This year and a custom range from S14', (tester) async {
    await app.pump(tester, location: Routes.export);
    await tapText(tester, 'This year');
    expect(find.text('2 tasks · 1 project'), findsOneWidget);

    await tapText(tester, 'Custom range');
    // This month to today.
    expect(find.text('Sun, 1 Nov 2026'), findsOneWidget);
    expect(find.text('Tue, 17 Nov 2026'), findsOneWidget);
    expect(find.text('2 tasks · 1 project'), findsOneWidget);

    await tapText(tester, 'From');
    await tester.tap(
      find
          .descendant(of: find.byType(MonthCalendar), matching: find.text('3'))
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PrimaryButton).last);
    await tester.pumpAndSettle();
    expect(find.text('Tue, 3 Nov 2026'), findsOneWidget);
    // Task 2 (2 Nov) is now outside.
    expect(find.text('1 task · 1 project'), findsOneWidget);
  });

  testWidgets('S35 opens Export data', (tester) async {
    await app.pump(tester, location: Routes.settings);
    expect(find.text('CSV or JSON'), findsOneWidget);
    await tapText(tester, 'Export data');
    expect(find.byType(ExportScreen), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('S41 lays out at 200% in ${brightness.name}', (tester) async {
      await app.pump(
        tester,
        location: Routes.export,
        brightness: brightness,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      await tapText(tester, 'Custom range');
      expect(tester.takeException(), isNull);
    });
  }
}
