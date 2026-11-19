import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/presentation/project_form_screen.dart';
import 'package:ctrltask/features/projects/presentation/projects_screen.dart';
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
        description: 'Marketing site',
      ),
      testProject(2, 'Q4 report'),
    ];
    app.taskList.value = [
      testTask(1, 'Copy', projectId: 1),
      testTask(2, 'Layout', projectId: 1),
    ];
    app.counts.value = {1: 2};
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

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
  }

  Finder nameField() => find.byType(TextField).first;

  group('new', () {
    testWidgets('Create project needs a name', (tester) async {
      await app.pump(tester, location: Routes.newProject);
      expect(find.text('New project'), findsOneWidget);
      expect(
        tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
        isNull,
      );
    });

    testWidgets('creates with the colour, icon and deadline picked', (
      tester,
    ) async {
      await app.pump(tester, go: Routes.projects, location: Routes.newProject);
      await tester.enterText(nameField(), 'Side hustle');
      await tester.enterText(find.byType(TextField).at(1), 'Candles');
      await tester.tap(find.bySemanticsLabel('Yellow'));
      // Past the first six, the row scrolls sideways.
      await tester.ensureVisible(find.bySemanticsLabel('Gift'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Gift'));
      await tester.pump();

      await tapText(tester, 'Deadline');
      // A deadline has no time.
      expect(find.text('No time'), findsNothing);
      await tapText(tester, 'Tomorrow');
      await tester.tap(find.text('Set Wed, 18 Nov'));
      await tester.pumpAndSettle();
      expect(find.text('Wed, 18 Nov 2026'), findsOneWidget);

      await save(tester);
      verify(
        () => app.projects.add(
          name: 'Side hustle',
          colorKey: ProjectColorKey.yellow,
          iconKey: ProjectIconKey.gift,
          description: 'Candles',
          deadline: DateTime(2026, 11, 18),
        ),
      ).called(1);
      expect(find.byType(ProjectFormScreen), findsNothing);
      expect(find.text('Side hustle'), findsOneWidget);
    });

    testWidgets('a deadline can be removed again', (tester) async {
      await app.pump(tester, location: Routes.newProject);
      await tapText(tester, 'Deadline');
      await tapText(tester, 'Today');
      await tester.tap(find.byType(PrimaryButton).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Remove deadline'));
      await tester.pump();
      expect(find.text('No deadline'), findsOneWidget);
    });

    testWidgets('a name in use says so and stays', (tester) async {
      await app.pump(tester, location: Routes.newProject);
      await tester.enterText(nameField(), 'q4 report');
      await tester.pump();
      await save(tester);
      expect(
        find.text('You already have a project called “q4 report”'),
        findsOneWidget,
      );
      expect(find.byType(ProjectFormScreen), findsOneWidget);
      // Typing clears it.
      await tester.enterText(nameField(), 'Q5 report');
      await tester.pump();
      expect(find.textContaining('You already have'), findsNothing);
    });

    testWidgets('a preset fills the name, colour and icon', (tester) async {
      await app.pump(tester, go: Routes.projects);
      app.router
          .push(
            Routes.newProject,
            extra: (
              name: 'Travel',
              color: ProjectColorKey.pink,
              icon: ProjectIconKey.plane,
            ),
          )
          .ignore();
      await tester.pumpAndSettle();
      await save(tester);
      verify(
        () => app.projects.add(
          name: 'Travel',
          colorKey: ProjectColorKey.pink,
          iconKey: ProjectIconKey.plane,
          description: any(named: 'description'),
          deadline: any(named: 'deadline'),
        ),
      ).called(1);
    });
  });

  group('edit', () {
    Future<void> pumpEdit(WidgetTester tester) => app.pump(
      tester,
      go: Routes.projects,
      location: Routes.editProject('1'),
    );

    testWidgets('loads the project and saves changes', (tester) async {
      await pumpEdit(tester);
      expect(find.text('Edit project'), findsOneWidget);
      expect(find.text('Website redesign'), findsOneWidget);
      expect(find.text('Marketing site'), findsOneWidget);
      expect(find.text('Mon, 30 Nov 2026'), findsOneWidget);

      await tester.enterText(nameField(), 'Website v2');
      await tester.tap(find.bySemanticsLabel('Green'));
      await tester.pump();
      await save(tester);
      final saved =
          verify(() => app.projects.update(captureAny())).captured.single
              as Project;
      expect(
        (saved.id, saved.name, saved.colorKey, saved.deadline),
        (1, 'Website v2', ProjectColorKey.green, DateTime(2026, 11, 30)),
      );
      expect(find.text('Website v2'), findsOneWidget);
    });

    testWidgets('Archive project archives it and goes to Projects', (
      tester,
    ) async {
      await pumpEdit(tester);
      await tapText(tester, 'Archive project');
      verify(() => app.projects.archive(1)).called(1);
      expect(find.byType(ProjectsScreen), findsOneWidget);
      expect(find.text('Archived · 1'), findsOneWidget);
    });

    testWidgets('Delete asks; Move tasks to Inbox is the default', (
      tester,
    ) async {
      await pumpEdit(tester);
      await tapText(tester, 'Delete project');
      expect(find.text('Delete Website redesign?'), findsOneWidget);
      expect(
        find.text("What should happen to its 2 tasks? This can't be undone."),
        findsOneWidget,
      );
      await tapText(tester, 'Move tasks to Inbox');
      verify(() => app.projects.delete(1, deleteTasks: false)).called(1);
      expect(find.byType(ProjectsScreen), findsOneWidget);
    });

    testWidgets('Delete tasks too deletes them', (tester) async {
      await pumpEdit(tester);
      await tapText(tester, 'Delete project');
      await tapText(tester, 'Delete tasks too');
      verify(() => app.projects.delete(1, deleteTasks: true)).called(1);
    });

    testWidgets('Cancel in the dialog keeps it', (tester) async {
      await pumpEdit(tester);
      await tapText(tester, 'Delete project');
      await tester.tap(find.text('Cancel').last);
      await tester.pumpAndSettle();
      verifyNever(
        () =>
            app.projects.delete(any(), deleteTasks: any(named: 'deleteTasks')),
      );
    });

    testWidgets('a project without tasks just asks to delete', (tester) async {
      app.counts.value = const {};
      await pumpEdit(tester);
      await tapText(tester, 'Delete project');
      expect(find.text("This can't be undone."), findsOneWidget);
      expect(find.text('Delete tasks too'), findsNothing);
      await tester.tap(find.text('Delete project').last);
      await tester.pumpAndSettle();
      verify(() => app.projects.delete(1, deleteTasks: false)).called(1);
    });
  });

  for (final brightness in Brightness.values) {
    testWidgets('lays out at 200% text in ${brightness.name}', (tester) async {
      await app.pump(
        tester,
        location: Routes.editProject('1'),
        brightness: brightness,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(AppChip), findsNothing);
    });
  }
}
