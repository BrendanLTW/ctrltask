import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/features/tags/domain/tag.dart';
import 'package:ctrltask/features/tags/presentation/tags_manager_screen.dart';
import 'package:ctrltask/features/tags/presentation/tags_sheet.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/presentation/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../projects/presentation/projects_app.dart';

void main() {
  late ProjectsApp app;
  const design = Tag(id: 1, name: 'design');
  const review = Tag(id: 2, name: 'review');
  const errands = Tag(id: 3, name: 'errands');
  TaskDetails? saved;

  setUpAll(() {
    registerProjectFallbacks();
    registerFallbackValue(TaskDetails(task: testTask(0, '')));
  });

  setUp(() {
    saved = null;
    app = ProjectsApp();
    app.tags.value = [
      (tag: design, taskCount: 14),
      (tag: errands, taskCount: 9),
      (tag: review, taskCount: 6),
    ];
    app.taskList.value = [testTask(1, 'Wireframes')];
    when(() => app.tasks.watchDetails(any())).thenAnswer(
      (_) => app.taskList.stream.map(
        (all) => saved ?? TaskDetails(task: all.first, tags: const [design]),
      ),
    );
    when(() => app.tasks.update(any())).thenAnswer((i) async {
      saved = i.positionalArguments.single as TaskDetails;
      app.taskList.value = [...app.taskList.value];
    });
    when(() => app.tasks.search(any())).thenAnswer((_) => Stream.value([]));
  });

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byType(PrimaryButton).last);
    await tester.pumpAndSettle();
  }

  group('S18', () {
    /// S12 for task 1, with S18 open from its tag chips.
    Future<void> openFromDetail(WidgetTester tester) async {
      await app.pump(tester, location: Routes.task('1'));
      await tester.tap(find.text('#design').first);
      await tester.pumpAndSettle();
      expect(find.byType(TagsSheet), findsOneWidget);
    }

    testWidgets('lists every tag with counts; the picked ones as chips', (
      tester,
    ) async {
      await openFromDetail(tester);
      for (final text in ['#design', '#errands', '#review', '14', '9', '6']) {
        expect(find.text(text), findsWidgets, reason: text);
      }
      expect(find.text('Save 1 tag'), findsOneWidget);
    });

    testWidgets('ticking and unticking change the Save count, and saves', (
      tester,
    ) async {
      await openFromDetail(tester);
      await tapText(tester, '#review');
      expect(find.text('Save 2 tags'), findsOneWidget);
      // Tapping a chip removes it.
      await tester.tap(
        find
            .descendant(
              of: find.byType(TagsSheet),
              matching: find.text('#design'),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Save 1 tag'), findsOneWidget);
      await save(tester);
      expect(saved!.tags, [review]);
    });

    testWidgets('search narrows; an unknown name can be created', (
      tester,
    ) async {
      await openFromDetail(tester);
      await tester.enterText(find.byType(TextField), 'err');
      await tester.pump();
      Finder inSheet(String text) => find.descendant(
        of: find.byType(TagsSheet),
        matching: find.text(text),
      );
      expect(inSheet('#design'), findsOneWidget, reason: 'its chip only');
      expect(inSheet('#errands'), findsOneWidget);
      expect(find.textContaining('Create tag'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '#Client');
      await tester.pump();
      await tapText(tester, 'Create tag “#client”');
      expect(app.tags.value.any((u) => u.tag.name == 'client'), isTrue);
      expect(find.text('Save 2 tags'), findsOneWidget, reason: 'ticked');
    });

    testWidgets('an existing name offers no Create', (tester) async {
      await openFromDetail(tester);
      await tester.enterText(find.byType(TextField), 'REVIEW');
      await tester.pump();
      expect(find.textContaining('Create tag'), findsNothing);
    });

    testWidgets('closing changes nothing', (tester) async {
      await openFromDetail(tester);
      await tapText(tester, '#review');
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      verifyNever(() => app.tasks.update(any()));
    });

    testWidgets('S11: the Tags row saves with the task', (tester) async {
      await app.pump(tester, location: Routes.newTask);
      await tester.enterText(find.byType(TextField).first, 'Moodboard');
      await tapText(tester, 'Tag');
      await tapText(tester, '#design');
      await save(tester);
      expect(find.text('#design'), findsOneWidget);
      await tapText(tester, 'Save');
      final draft =
          verify(() => app.tasks.add(captureAny())).captured.single
              as TaskDraft;
      expect(draft.tagIds, {design.id});
    });

    testWidgets('S10: the 🏷 button picks tags for the new task', (
      tester,
    ) async {
      await app.pump(tester);
      await tester.tap(find.byTooltip('Quick add task'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Call bank');
      await tester.pump();
      await tester.tap(find.byTooltip('Tags'));
      await tester.pumpAndSettle();
      await tapText(tester, '#errands');
      await save(tester);
      expect(find.byTooltip('Tags · 1'), findsOneWidget);
      await tester.tap(find.byTooltip('Add task'));
      await tester.pumpAndSettle();
      final draft =
          verify(() => app.tasks.add(captureAny())).captured.single
              as TaskDraft;
      expect(draft.tagIds, {errands.id});
    });
  });

  group('S46', () {
    Future<void> pump(WidgetTester tester) =>
        app.pump(tester, location: Routes.tags);

    testWidgets('most used first, with counts and search', (tester) async {
      await pump(tester);
      expect(find.text('Search 3 tags'), findsOneWidget);
      expect(find.text('14 tasks'), findsOneWidget);
      final design = tester.getTopLeft(find.text('design')).dy;
      final review = tester.getTopLeft(find.text('review')).dy;
      expect(design, lessThan(review));
      expect(
        find.text('Tap a tag here to rename, merge or delete it.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField), '#rev');
      await tester.pump();
      expect(find.text('design'), findsNothing);
      expect(find.text('review'), findsOneWidget);
    });

    testWidgets('Add creates a tag; a taken name says so', (tester) async {
      await pump(tester);
      await tapText(tester, 'Add');
      await tester.enterText(find.byType(TextField).last, 'Finance');
      await tester.pump();
      await save(tester);
      expect(find.text('finance'), findsOneWidget);

      await tapText(tester, 'Add');
      await tester.enterText(find.byType(TextField).last, 'design');
      await tester.pump();
      await save(tester);
      expect(find.text('You already have #design'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('Rename renames', (tester) async {
      await pump(tester);
      await tapText(tester, 'errands');
      await tapText(tester, 'Rename');
      await tester.enterText(find.byType(TextField).last, 'chores');
      await tester.pump();
      await save(tester);
      expect(find.text('chores'), findsOneWidget);
      expect(find.text('errands'), findsNothing);
    });

    testWidgets('renaming onto a tag asks, then merges', (tester) async {
      await pump(tester);
      await tapText(tester, 'review');
      await tapText(tester, 'Rename');
      await tester.enterText(find.byType(TextField).last, 'design');
      await tester.pump();
      await save(tester);
      expect(find.text('Merge #review into #design?'), findsOneWidget);
      await tapText(tester, 'Merge');
      expect(find.text('review'), findsNothing);
      expect(find.text('20 tasks'), findsOneWidget);
    });

    testWidgets('Delete asks first', (tester) async {
      await pump(tester);
      await tapText(tester, 'errands');
      await tapText(tester, 'Delete tag');
      expect(find.text('Delete #errands?'), findsOneWidget);
      expect(
        find.text("It comes off 9 tasks. This can't be undone."),
        findsOneWidget,
      );
      await tapText(tester, 'Delete tag');
      expect(find.text('errands'), findsNothing);
    });

    testWidgets('Show tasks searches the tag', (tester) async {
      await pump(tester);
      await tapText(tester, 'design');
      await tapText(tester, 'Show tasks');
      expect(
        tester.widget<SearchScreen>(find.byType(SearchScreen)).initialQuery,
        '#design',
      );
      verify(() => app.tasks.search('#design')).called(greaterThan(0));
    });

    testWidgets('opens from Settings with the count', (tester) async {
      await app.pump(tester, location: Routes.settings);
      await tapText(tester, 'Tags');
      expect(find.byType(TagsManagerScreen), findsOneWidget);
    });

    testWidgets('no tags yet', (tester) async {
      app.tags.value = [];
      await pump(tester);
      expect(find.text('No tags yet'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });
  });

  for (final brightness in Brightness.values) {
    testWidgets('S18 and S46 lay out at 200% in ${brightness.name}', (
      tester,
    ) async {
      await app.pump(
        tester,
        location: Routes.tags,
        brightness: brightness,
        textScale: 2,
      );
      expect(tester.takeException(), isNull, reason: 'S46');
      app.router.push(Routes.task('1')).ignore();
      await tester.pumpAndSettle();
      await tester.tap(find.text('#design').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'S18');
    });
  }
}
