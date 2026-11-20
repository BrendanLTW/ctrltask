import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/core/widgets/swipe_actions.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/features/tasks/presentation/quick_add_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../projects/presentation/projects_app.dart';

void main() {
  late ProjectsApp app;
  final today = DateTime(2026, 11, 17);

  Task task(
    int id,
    String title, {
    DateTime? due,
    int? projectId,
    TaskPriority priority = TaskPriority.medium,
    bool done = false,
  }) => testTask(id, title, dueDate: due, projectId: projectId, done: done)
      .copyWith(
        priority: priority,
        completedAt: done ? DateTime(2026, 11, 17, 8).toUtc() : null,
      );

  setUpAll(() {
    registerProjectFallbacks();
    registerFallbackValue(TaskDetails(task: testTask(0, '')));
  });

  setUp(() {
    app = ProjectsApp();
    app.active.value = [
      testProject(4, 'Freelance', color: ProjectColorKey.yellow),
    ];
    app.taskList.value = [
      task(
        1,
        'Send invoice',
        due: DateTime(2026, 11, 16),
        projectId: 4,
        priority: TaskPriority.high,
      ),
      task(2, 'Slides', due: today, priority: TaskPriority.urgent),
      task(3, 'Call', due: today),
      task(4, 'Gym', due: today, done: true),
      task(5, 'Tiles', due: DateTime(2026, 11, 18)),
      task(6, 'Pricing', due: DateTime(2026, 11, 19)),
      task(7, 'Dentist', due: DateTime(2026, 11, 26)),
      task(8, 'Read'),
    ];
    when(() => app.tasks.watchDetails(any())).thenAnswer((i) {
      final id = i.positionalArguments.single as int;
      return Stream.value(
        TaskDetails(task: app.taskList.value.firstWhere((t) => t.id == id)),
      );
    });
    when(() => app.tasks.update(any())).thenAnswer((i) async {
      final task = (i.positionalArguments.single as TaskDetails).task;
      app.taskList.value = [
        for (final t in app.taskList.value)
          if (t.id == task.id) task else t,
      ];
    });
    when(() => app.tasks.delete(any())).thenAnswer((i) async {
      final id = i.positionalArguments.single as int;
      final gone = app.taskList.value.firstWhere((t) => t.id == id);
      app.taskList.value = [...app.taskList.value]..remove(gone);
      return TaskDetails(task: gone);
    });
  });

  Future<void> pump(WidgetTester tester) => app.pump(tester, go: Routes.tasks);

  /// Scrolls chips in the sideways row into view first.
  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Finder chip(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(InkWell));

  Future<void> swipeLeft(WidgetTester tester, String title) async {
    await tester.drag(find.text(title), const Offset(-200, 0));
    await tester.pumpAndSettle();
  }

  testWidgets('All shows every section with its detail', (tester) async {
    await pump(tester);
    for (final text in [
      'OVERDUE',
      '1 task',
      'TODAY · TUE 17',
      '2 of 3 left',
      'TOMORROW',
      'Swipe for quick actions',
      'THIS WEEK',
      'LATER',
      'NO DATE',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    // The overdue day stands alone under the red header.
    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.textContaining('Thu, 19 Nov'), findsOneWidget);
  });

  testWidgets('chips show counts and filter the list', (tester) async {
    await pump(tester);
    for (final (label, count) in [
      ('All', '8'),
      ('Today', '3'),
      ('Upcoming', '3'),
      ('High priority', '2'),
      ('Done', '1'),
    ]) {
      expect(
        find.descendant(of: chip(label), matching: find.text(count)),
        findsOneWidget,
        reason: label,
      );
    }

    await tapText(tester, 'Upcoming');
    expect(find.text('Tiles'), findsOneWidget);
    expect(find.text('Slides'), findsNothing);

    await tapText(tester, 'High priority');
    expect(find.text('Slides'), findsOneWidget);
    expect(find.text('Send invoice'), findsOneWidget);
    expect(find.text('Call'), findsNothing);

    await tapText(tester, 'Done');
    expect(find.text('DONE'), findsOneWidget);
    expect(find.text('Gym'), findsOneWidget);
    expect(find.text('Slides'), findsNothing);
  });

  testWidgets('counts and sections update live', (tester) async {
    await pump(tester);
    app.taskList.value = [
      ...app.taskList.value,
      task(9, 'New today', due: today),
    ];
    await tester.pumpAndSettle();
    expect(find.text('3 of 4 left'), findsOneWidget);
    expect(
      find.descendant(of: chip('All'), matching: find.text('9')),
      findsOneWidget,
    );
  });

  group('empty', () {
    testWidgets('All offers to add a task', (tester) async {
      app.taskList.value = const [];
      await pump(tester);
      expect(find.text('No tasks yet'), findsOneWidget);
      await tapText(tester, 'Add a task');
      expect(find.byType(QuickAddSheet), findsOneWidget);
    });

    for (final (chipLabel, title) in [
      ('Today', 'Nothing due today'),
      ('Upcoming', 'Nothing coming up'),
      ('High priority', 'No high-priority tasks'),
      ('Done', 'Nothing done yet'),
    ]) {
      testWidgets('$chipLabel says $title', (tester) async {
        app.taskList.value = [task(1, 'Read')];
        await pump(tester);
        await tapText(tester, chipLabel);
        expect(find.text(title), findsOneWidget);
      });
    }
  });

  group('swipe', () {
    testWidgets('right completes, with the toast and Undo', (tester) async {
      await pump(tester);
      await tester.drag(find.text('Tiles'), const Offset(250, 0));
      await tester.pumpAndSettle();
      verify(() => app.tasks.complete(5)).called(1);
      expect(find.text('Nice. “Tiles” is done'), findsOneWidget);
      await tapText(tester, 'Undo');
      verify(() => app.tasks.undoComplete(any())).called(1);
    });

    testWidgets('a short swipe right springs back', (tester) async {
      await pump(tester);
      await tester.drag(find.text('Tiles'), const Offset(40, 0));
      await tester.pumpAndSettle();
      verifyNever(() => app.tasks.complete(any()));
    });

    testWidgets('left reveals Reschedule, which saves a new date', (
      tester,
    ) async {
      await pump(tester);
      await swipeLeft(tester, 'Tiles');
      await tapText(tester, 'Reschedule');
      await tapText(tester, 'Next week');
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();
      final saved =
          verify(() => app.tasks.update(captureAny())).captured.single
              as TaskDetails;
      expect(saved.task.dueDate, DateTime(2026, 11, 23));
      expect(find.text('LATER'), findsOneWidget);
    });

    testWidgets('a tap closes the revealed actions', (tester) async {
      await pump(tester);
      await swipeLeft(tester, 'Tiles');
      expect(find.text('Reschedule'), findsOneWidget);
      await tester.tapAt(
        tester.getTopLeft(find.byType(SwipeActions).at(4)) +
            const Offset(20, 20),
      );
      await tester.pumpAndSettle();
      expect(find.text('Reschedule'), findsNothing);
    });

    for (final (choice, deletes, completes) in [
      ('Delete task', true, false),
      ('Mark as done instead', false, true),
      ('Cancel', false, false),
    ]) {
      testWidgets('Delete asks first: $choice', (tester) async {
        await pump(tester);
        await swipeLeft(tester, 'Send invoice');
        await tapText(tester, 'Delete');
        expect(
          find.text(
            '“Send invoice” will be removed from Freelance. '
            "This can't be undone.",
          ),
          findsOneWidget,
        );
        await tapText(tester, choice);
        if (deletes) {
          verify(() => app.tasks.delete(1)).called(1);
          expect(find.text('Send invoice'), findsNothing);
        } else {
          verifyNever(() => app.tasks.delete(any()));
        }
        if (completes) verify(() => app.tasks.complete(1)).called(1);
        await tester.pump(const Duration(seconds: 4));
      });
    }

    testWidgets('screen readers get each action', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester);
      final node = tester.getSemantics(find.byType(SwipeActions).at(4));
      final labels = [
        for (final id in node.getSemanticsData().customSemanticsActionIds!)
          CustomSemanticsAction.getAction(id)!.label,
      ];
      expect(labels, ['Complete', 'Reschedule', 'Delete']);

      final complete = CustomSemanticsAction.getIdentifier(
        const CustomSemanticsAction(label: 'Complete'),
      );
      node.owner!.performAction(
        node.id,
        SemanticsAction.customAction,
        complete,
      );
      await tester.pumpAndSettle();
      verify(() => app.tasks.complete(5)).called(1);
      await tester.pump(const Duration(seconds: 4));
      handle.dispose();
    });

    testWidgets('done rows do not swipe to complete', (tester) async {
      await pump(tester);
      await tapText(tester, 'Done');
      await tester.drag(find.text('Gym'), const Offset(250, 0));
      await tester.pumpAndSettle();
      verifyNever(() => app.tasks.complete(any()));
    });
  });

  for (final brightness in Brightness.values) {
    testWidgets('lays out at 200% text in ${brightness.name}', (tester) async {
      await app.pump(
        tester,
        go: Routes.tasks,
        brightness: brightness,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      await tester.drag(find.text('Read'), const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
