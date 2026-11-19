import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/features/projects/presentation/move_to_project_sheet.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'projects_app.dart';

void main() {
  late ProjectsApp app;

  setUpAll(() {
    registerProjectFallbacks();
    registerFallbackValue(TaskDetails(task: testTask(0, '')));
  });

  setUp(() {
    app = ProjectsApp();
    app.active.value = [
      testProject(1, 'Website redesign'),
      testProject(2, 'Q4 report'),
    ];
    app.taskList.value = [
      testTask(1, 'Copy', projectId: 1),
      testTask(2, 'Layout', projectId: 1),
      testTask(3, 'Done', projectId: 1, done: true),
      testTask(4, 'Numbers', projectId: 2),
    ];
    when(() => app.tasks.watchDetails(1)).thenAnswer(
      (_) => app.taskList.stream.map(
        (all) => TaskDetails(task: all.firstWhere((t) => t.id == 1)),
      ),
    );
    when(() => app.tasks.update(any())).thenAnswer((i) async {
      final task = (i.positionalArguments.single as TaskDetails).task;
      app.taskList.value = [
        for (final t in app.taskList.value)
          if (t.id == task.id) task else t,
      ];
    });
  });

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  /// S12 for task 1, with the sheet open from its project chip.
  Future<void> openFromDetail(WidgetTester tester) async {
    await app.pump(tester, location: Routes.task('1'));
    await tapText(tester, 'Website redesign');
    expect(find.byType(MoveToProjectSheet), findsOneWidget);
  }

  ListGroupRow row(WidgetTester tester, String title) => tester.widget(
    find.byWidgetPredicate((w) => w is ListGroupRow && w.title == title),
  );

  testWidgets('lists Inbox and projects with open counts, ticking the '
      'current one', (tester) async {
    await openFromDetail(tester);
    expect(find.text('No project'), findsOneWidget);
    expect(find.text('2 open'), findsOneWidget);
    expect(find.text('1 open'), findsOneWidget);
    expect(row(tester, 'Website redesign').selected, isTrue);
    expect(row(tester, 'Inbox').selected, isFalse);
  });

  testWidgets('search narrows the list', (tester) async {
    await openFromDetail(tester);
    await tester.enterText(find.byType(TextField), 'q4');
    await tester.pump();
    expect(find.text('Q4 report'), findsOneWidget);
    expect(find.text('Inbox'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) => w is ListGroupRow && w.title == 'Website redesign',
      ),
      findsNothing,
    );
    expect(find.text('New project'), findsOneWidget);
  });

  testWidgets('S12: choosing moves the task and closes', (tester) async {
    await openFromDetail(tester);
    await tapText(tester, 'Q4 report');
    expect(find.byType(MoveToProjectSheet), findsNothing);
    final saved =
        verify(() => app.tasks.update(captureAny())).captured.single
            as TaskDetails;
    expect(saved.task.projectId, 2);
    expect(find.text('Q4 report'), findsOneWidget);
  });

  testWidgets('S12: Inbox takes it out of its project', (tester) async {
    await openFromDetail(tester);
    await tapText(tester, 'Inbox');
    final saved =
        verify(() => app.tasks.update(captureAny())).captured.single
            as TaskDetails;
    expect(saved.task.projectId, isNull);
  });

  testWidgets('closing changes nothing', (tester) async {
    await openFromDetail(tester);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    verifyNever(() => app.tasks.update(any()));
  });

  testWidgets('S11: New project creates one and picks it', (tester) async {
    await app.pump(tester, location: Routes.newTask);
    await tapText(tester, 'Project');
    await tapText(tester, 'New project');
    await tester.enterText(find.byType(TextField).first, 'Garden');
    await tester.pump();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(find.text('New task'), findsOneWidget);
    expect(find.text('Garden'), findsOneWidget);
  });

  testWidgets('S10: the project chip changes where the task goes', (
    tester,
  ) async {
    await app.pump(tester);
    await tester.tap(find.byTooltip('Quick add task'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Inbox');
    await tapText(tester, 'Q4 report');
    expect(find.text('Q4 report'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Charts');
    await tester.pump();
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
    final draft =
        verify(() => app.tasks.add(captureAny())).captured.single as TaskDraft;
    expect(draft.projectId, 2);
  });

  for (final brightness in Brightness.values) {
    testWidgets('lays out at 200% text in ${brightness.name}', (tester) async {
      await app.pump(
        tester,
        location: Routes.task('1'),
        brightness: brightness,
        textScale: 2,
      );
      await tapText(tester, 'Website redesign');
      expect(tester.takeException(), isNull);
    });
  }
}
