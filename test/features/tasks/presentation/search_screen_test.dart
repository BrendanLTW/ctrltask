import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/task_row.dart';
import 'package:ctrltask/features/projects/presentation/project_detail_screen.dart';
import 'package:ctrltask/features/tasks/domain/recent_searches_repository.dart';
import 'package:ctrltask/features/tasks/presentation/quick_add_sheet.dart';
import 'package:ctrltask/features/tasks/presentation/search_screen.dart';
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
      testProject(
        4,
        'Freelance',
        description: 'Use the invoice template in Drive',
      ),
      testProject(5, 'Garden'),
    ];
    app.taskList.value = [
      testTask(
        1,
        'Send invoice to Lumen Studio',
        projectId: 4,
        dueDate: DateTime(2026, 11, 16),
      ),
      testTask(2, 'Chase invoice #0418', projectId: 4),
      testTask(3, 'File October invoices', done: true),
      testTask(4, 'Plant bulbs', projectId: 5),
    ];
    // The repository's search, over titles here.
    when(() => app.tasks.search(any())).thenAnswer((i) {
      final q = (i.positionalArguments.single as String).trim().toLowerCase();
      return app.taskList.stream.map(
        (all) => [
          for (final t in all)
            if (q.isNotEmpty && t.title.toLowerCase().contains(q)) t,
        ],
      );
    });
  });

  Future<void> pump(WidgetTester tester) =>
      app.pump(tester, location: Routes.search);

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  RecentSearchesRepository recent() =>
      app.container.read(recentSearchesRepositoryProvider);

  testWidgets('results with type chips and counts', (tester) async {
    await pump(tester);
    await type(tester, 'INVOICE');
    for (final (label, count) in [
      ('All', '4'),
      ('Tasks', '3'),
      ('Projects', '1'),
      ('Done', '1'),
    ]) {
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text(label),
            matching: find.byType(InkWell),
          ),
          matching: find.text(count),
        ),
        findsOneWidget,
        reason: label,
      );
    }
    expect(find.text('Overdue · Mon, 16 Nov'), findsOneWidget);
    expect(find.textContaining('Done · '), findsOneWidget);

    await tapText(tester, 'Done');
    expect(find.text('File October invoices'), findsOneWidget);
    expect(find.text('Chase invoice #0418'), findsNothing);
    expect(find.text('Freelance'), findsNothing);

    await tapText(tester, 'Projects');
    expect(find.text('TASKS'), findsNothing);
    expect(find.text('Freelance'), findsOneWidget);
  });

  testWidgets('the match is highlighted in each title', (tester) async {
    await pump(tester);
    await type(tester, 'invoice');
    final row = tester.widget<TaskRow>(find.byType(TaskRow).first);
    expect(row.data.titleMatches, [(start: 5, end: 12)]);
  });

  testWidgets("a project's note shows where it matched", (tester) async {
    await pump(tester);
    await type(tester, 'invoice');
    expect(
      find.text('Note matches “Use the invoice template in Drive”'),
      findsOneWidget,
    );
    await tapText(tester, 'Freelance');
    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    expect(await recent().watch().first, ['invoice']);
  });

  testWidgets('recent searches: saved on submit, run again, cleared', (
    tester,
  ) async {
    await pump(tester);
    await type(tester, 'bulbs');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await type(tester, '');
    expect(find.text('RECENT SEARCHES'), findsOneWidget);

    await tapText(tester, 'bulbs');
    expect(find.text('Plant bulbs'), findsOneWidget);

    await type(tester, '');
    await tapText(tester, 'Clear');
    expect(find.text('RECENT SEARCHES'), findsNothing);
  });

  testWidgets('S25: no matches, with did you mean', (tester) async {
    await pump(tester);
    await type(tester, 'invoce');
    expect(find.text('No matches for “invoce”'), findsOneWidget);
    expect(
      find.text(
        'Nothing in your tasks, projects or tags. Check the spelling or '
        'try a shorter word.',
      ),
      findsOneWidget,
    );
    await tapText(tester, 'Did you mean invoice?');
    expect(find.text('Send invoice to Lumen Studio'), findsOneWidget);
  });

  testWidgets('S25: Create task opens quick add with the words', (
    tester,
  ) async {
    await pump(tester);
    await type(tester, 'buy stamps');
    expect(find.textContaining('Did you mean'), findsNothing);
    await tapText(tester, 'Create task “buy stamps”');
    expect(
      tester.widget<QuickAddSheet>(find.byType(QuickAddSheet)).title,
      'buy stamps',
    );
  });

  testWidgets('Cancel goes back', (tester) async {
    await pump(tester);
    await tapText(tester, 'Cancel');
    expect(find.byType(SearchScreen), findsNothing);
  });

  for (final brightness in Brightness.values) {
    testWidgets('S24 and S25 lay out at 200% in ${brightness.name}', (
      tester,
    ) async {
      await app.pump(
        tester,
        location: Routes.search,
        brightness: brightness,
        textScale: 2,
      );
      await type(tester, 'invoice');
      expect(tester.takeException(), isNull, reason: 'S24');
      await type(tester, 'invoce');
      expect(tester.takeException(), isNull, reason: 'S25');
    });
  }
}
