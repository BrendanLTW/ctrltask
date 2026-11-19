import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/task_checkbox.dart';
import 'package:ctrltask/features/projects/presentation/project_form_screen.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/presentation/task_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'projects_app.dart';

void main() {
  late ProjectsApp app;

  setUpAll(registerProjectFallbacks);

  setUp(() {
    app = ProjectsApp();
    app.active.value = [
      testProject(
        1,
        'Website redesign',
        deadline: DateTime(2026, 11, 30),
        description: 'New marketing site.',
      ),
    ];
    app.taskList.value = [
      testTask(1, 'Review homepage wireframes', projectId: 1, dueDate: today),
      testTask(2, 'Write homepage copy', projectId: 1),
      testTask(3, 'Pricing page layout', projectId: 1),
      for (final (i, title) in ['Moodboard', 'Sitemap', 'Kick-off'].indexed)
        testTask(10 + i, title, projectId: 1, done: true),
      testTask(20, 'Elsewhere'),
    ];
    app.focused.value = 3 * 3600 + 20 * 60;
  });

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(
      find.text(text),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<void> pump(WidgetTester tester) =>
      app.pump(tester, location: Routes.project('1'));

  testWidgets('the header shows deadline, progress and focus time', (
    tester,
  ) async {
    await pump(tester);
    for (final text in [
      'Website redesign',
      'Due Mon, 30 Nov · 13 days left',
      'New marketing site.',
      '50%',
      '3 of 6 tasks done · 3h 20m focused',
      'OPEN · 3',
      'Add task to Website redesign',
      'Completed',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('Elsewhere'), findsNothing);
  });

  testWidgets('no focus yet leaves the time off', (tester) async {
    app.focused.value = 0;
    await pump(tester);
    expect(find.text('3 of 6 tasks done'), findsOneWidget);
  });

  testWidgets('open rows name their day', (tester) async {
    await pump(tester);
    expect(find.textContaining('Today'), findsOneWidget);
  });

  testWidgets('completing a task updates the counts live', (tester) async {
    await pump(tester);
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is TaskCheckbox && w.title == 'Pricing page layout',
      ),
    );
    await tester.pumpAndSettle();
    verify(() => app.tasks.complete(3)).called(1);
    expect(find.text('OPEN · 2'), findsOneWidget);
    expect(find.text('4'), findsOneWidget, reason: 'the Completed count');
    expect(find.text('67%'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('Completed shows the done tasks, and hides them again', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Sitemap'), findsNothing);
    final subtitle = tester.widget<Text>(
      // Most recently done first.
      find.text('Kick-off, Sitemap, Moodboard'),
    );
    expect(subtitle.maxLines, 2);

    await tapText(tester, 'Completed');
    expect(find.text('Sitemap'), findsOneWidget);
    await tapText(tester, 'Completed');
    expect(find.text('Sitemap'), findsNothing);
  });

  testWidgets('a row opens the task', (tester) async {
    await pump(tester);
    await tapText(tester, 'Write homepage copy');
    expect(
      tester.widget<TaskDetailScreen>(find.byType(TaskDetailScreen)).taskId,
      2,
    );
  });

  testWidgets('Add task opens quick add in this project', (tester) async {
    await pump(tester);
    await tapText(tester, 'Add task to Website redesign');
    await tester.enterText(find.byType(TextField), 'Footer');
    await tester.pump();
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
    final draft =
        verify(() => app.tasks.add(captureAny())).captured.single as TaskDraft;
    expect(draft.projectId, 1);
    expect(find.text('OPEN · 4'), findsOneWidget);
  });

  testWidgets('••• opens S28 to edit', (tester) async {
    await pump(tester);
    await tester.tap(find.byTooltip('Edit project'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ProjectFormScreen>(find.byType(ProjectFormScreen))
          .projectId,
      1,
    );
  });

  for (final brightness in Brightness.values) {
    testWidgets('lays out at 200% text in ${brightness.name}', (tester) async {
      await app.pump(
        tester,
        location: Routes.project('1'),
        brightness: brightness,
        textScale: 2,
      );
      await tapText(tester, 'Completed');
      expect(tester.takeException(), isNull);
    });
  }
}

final today = DateTime(2026, 11, 17);
