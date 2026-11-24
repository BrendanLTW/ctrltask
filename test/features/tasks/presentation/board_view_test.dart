import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/features/tasks/presentation/board/board_card.dart';
import 'package:ctrltask/features/tasks/presentation/board/board_view.dart';
import 'package:ctrltask/features/tasks/presentation/board/kanban_column.dart';
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
      testProject(1, 'Website redesign'),
      testProject(2, 'Q4 report'),
    ];
    app.taskList.value = [
      testTask(
        1,
        'Write homepage copy',
        projectId: 1,
        dueDate: DateTime(2026, 11, 20),
      ).copyWith(priority: TaskPriority.urgent),
      testTask(2, 'Set up analytics', projectId: 1),
      testTask(
        3,
        'Review wireframes',
        projectId: 1,
      ).copyWith(boardColumn: BoardColumn.doing),
      testTask(4, 'Moodboard', projectId: 1, done: true),
      testTask(5, 'Draft slides', projectId: 2),
    ];
    app.tagNames.value = {
      2: ['design'],
    };
  });

  Future<void> openBoard(WidgetTester tester) async {
    await app.pump(tester, location: Routes.tasks);
    await tester.tap(find.text('Board'));
    await tester.pumpAndSettle();
  }

  Finder column(BoardColumn c) =>
      find.byWidgetPredicate((w) => w is KanbanColumn && w.column == c);

  Finder inColumn(BoardColumn c, String title) =>
      find.descendant(of: column(c), matching: find.text(title));

  /// A card's screen-reader action, as TalkBack or VoiceOver runs it.
  void moveBySemantics(WidgetTester tester, String title, String action) {
    final semantics = tester.widget<Semantics>(
      find
          .descendant(
            of: find.byWidgetPredicate(
              (w) => w is BoardCard && w.task.title == title,
            ),
            matching: find.byType(Semantics),
          )
          .first,
    );
    semantics.properties.customSemanticsActions!.entries
        .firstWhere((e) => e.key.label == action)
        .value();
  }

  testWidgets("S20 shows the first project's tasks by status", (tester) async {
    await openBoard(tester);
    expect(find.text('Website redesign'), findsOneWidget);
    expect(find.text('Grouped by status'), findsOneWidget);
    expect(find.byType(BoardCard), findsNWidgets(4));
    expect(inColumn(BoardColumn.todo, 'Write homepage copy'), findsOneWidget);
    expect(inColumn(BoardColumn.doing, 'Review wireframes'), findsOneWidget);
    expect(inColumn(BoardColumn.done, 'Moodboard'), findsOneWidget);
    expect(find.text('Draft slides'), findsNothing, reason: 'other project');
    // The card: priority for Urgent and High, the date or No date, tags.
    expect(find.text('Urgent'), findsOneWidget);
    expect(find.text('Fri, 20 Nov'), findsOneWidget);
    expect(find.text('No date'), findsWidgets);
    expect(find.textContaining('design', findRichText: true), findsWidgets);
    // Counts, and Add task everywhere but Done.
    expect(
      find.descendant(of: column(BoardColumn.todo), matching: find.text('2')),
      findsOneWidget,
    );
    expect(find.text('Add task'), findsNWidgets(2));
  });

  testWidgets('long-press drags a card to another column', (tester) async {
    await openBoard(tester);
    final card = find.text('Set up analytics');
    final gesture = await tester.startGesture(tester.getCenter(card));
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(
      tester.getTopLeft(column(BoardColumn.doing)) + const Offset(40, 60),
    );
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    verify(() => app.tasks.moveToColumn(2, BoardColumn.doing)).called(1);
    expect(inColumn(BoardColumn.doing, 'Set up analytics'), findsOneWidget);
  });

  testWidgets('into Done completes it, with Undo', (tester) async {
    await openBoard(tester);
    moveBySemantics(tester, 'Set up analytics', 'Move to Done');
    await tester.pump(const Duration(milliseconds: 400));
    verify(() => app.tasks.complete(2)).called(1);
    expect(find.text('Undo'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(inColumn(BoardColumn.todo, 'Set up analytics'), findsOneWidget);
  });

  testWidgets('out of Done reopens it in that column', (tester) async {
    await openBoard(tester);
    moveBySemantics(tester, 'Moodboard', 'Move to In progress');
    await tester.pumpAndSettle();
    verify(() => app.tasks.uncomplete(4, into: BoardColumn.doing)).called(1);
    expect(inColumn(BoardColumn.doing, 'Moodboard'), findsOneWidget);
  });

  testWidgets('Add task starts the task in that column', (tester) async {
    await openBoard(tester);
    final add = find.descendant(
      of: column(BoardColumn.doing),
      matching: find.text('Add task'),
    );
    await tester.ensureVisible(add);
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).last, 'Write FAQ');
    await tester.pump();
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
    final draft =
        verify(() => app.tasks.add(captureAny())).captured.single as TaskDraft;
    expect((draft.projectId, draft.column), (1, BoardColumn.doing));
  });

  testWidgets('the project chip picks another project', (tester) async {
    await openBoard(tester);
    await tester.tap(find.text('Website redesign'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Q4 report').last);
    await tester.pumpAndSettle();
    expect(find.text('Draft slides'), findsOneWidget);
    expect(find.text('Write homepage copy'), findsNothing);
  });

  testWidgets("S27's Board view opens the board on that project", (
    tester,
  ) async {
    await app.pump(tester, location: '/project/2');
    await tester.tap(find.text('Board view'));
    await tester.pumpAndSettle();
    expect(find.byType(BoardView), findsOneWidget);
    expect(find.text('Draft slides'), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('S20 lays out at 200% in ${brightness.name}', (tester) async {
      await app.pump(
        tester,
        location: Routes.tasks,
        brightness: brightness,
        textScale: 2,
      );
      await tester.tap(find.text('Board'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
