import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/presentation/archived_projects.dart';
import 'package:ctrltask/features/projects/presentation/project_detail_screen.dart';
import 'package:ctrltask/features/projects/presentation/project_form_screen.dart';
import 'package:ctrltask/features/projects/presentation/projects_empty.dart';
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
      testProject(1, 'Website redesign', deadline: DateTime(2026, 11, 30)),
      testProject(
        2,
        'Q4 report',
        color: ProjectColorKey.orange,
        deadline: DateTime(2026, 11, 23),
      ),
      testProject(3, 'Home renovation', color: ProjectColorKey.green),
    ];
    app.archived.value = [
      testProject(5, 'Moving house', archivedAt: DateTime.utc(2026, 9, 2, 10)),
    ];
    app.counts.value = {5: 24};
    app.taskList.value = [
      for (var i = 0; i < 8; i++)
        testTask(i + 1, 'Web $i', projectId: 1, done: i < 5),
      testTask(20, 'Loose'),
    ];
  });

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  group('S26', () {
    testWidgets('cards show deadline, days left, progress and counts', (
      tester,
    ) async {
      await app.pump(tester, go: Routes.projects);
      for (final text in [
        'Active · 3',
        'Archived · 1',
        'Website redesign',
        'Due Mon, 30 Nov',
        '13 days left',
        '6 days left',
        'No deadline',
        '5 of 8 tasks',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(find.text('0 of 0 tasks'), findsNWidgets(2));
      expect(find.textContaining('63%'), findsOneWidget);
    });

    testWidgets('progress updates live', (tester) async {
      await app.pump(tester, go: Routes.projects);
      app.taskList.value = [
        ...app.taskList.value,
        testTask(30, 'Web new', projectId: 1),
      ];
      await tester.pumpAndSettle();
      expect(find.text('5 of 9 tasks'), findsOneWidget);
    });

    testWidgets('the days-left tag turns red at 7 days', (tester) async {
      await app.pump(tester, go: Routes.projects);
      Color tagColour(String text) =>
          tester.widget<Text>(find.text(text)).style!.color!;
      expect(tagColour('6 days left'), isNot(tagColour('13 days left')));
    });

    testWidgets('a past deadline reads Overdue', (tester) async {
      app.active.value = [
        testProject(1, 'Late', deadline: DateTime(2026, 11, 10)),
      ];
      await app.pump(tester, go: Routes.projects);
      expect(find.text('Overdue'), findsOneWidget);
    });

    testWidgets('a card opens its project', (tester) async {
      await app.pump(tester, go: Routes.projects);
      await tapText(tester, 'Q4 report');
      expect(
        tester
            .widget<ProjectDetailScreen>(find.byType(ProjectDetailScreen))
            .projectId,
        2,
      );
    });

    testWidgets('New opens S28', (tester) async {
      await app.pump(tester, go: Routes.projects);
      await tapText(tester, 'New');
      expect(find.text('New project'), findsOneWidget);
    });

    testWidgets('Archived shows S45 and Restore brings one back', (
      tester,
    ) async {
      await app.pump(tester, go: Routes.projects);
      await tapText(tester, 'Archived · 1');
      expect(find.text('24 tasks · finished 2 Sep'), findsOneWidget);
      expect(
        find.text(
          'Archived projects keep their tasks and stats. Restore one to '
          'move it back to Projects.',
        ),
        findsOneWidget,
      );

      await tapText(tester, 'Restore');
      verify(() => app.projects.restore(5)).called(1);
      expect(find.text('Moving house is active again'), findsOneWidget);
      // The last one restored: back to Active, where it now is.
      expect(find.text('Active · 4'), findsOneWidget);
      expect(find.text('Moving house'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });
  });

  group('S45', () {
    testWidgets('opens on its own with a back bar', (tester) async {
      await app.pump(tester, location: Routes.archivedProjects);
      expect(find.text('Archived projects'), findsOneWidget);
      expect(find.byType(ArchivedProjectsList), findsOneWidget);
    });

    testWidgets('a taken name says so and keeps it archived', (tester) async {
      app.archived.value = [
        testProject(5, 'Q4 report', archivedAt: DateTime.utc(2026, 9, 2)),
      ];
      await app.pump(tester, location: Routes.archivedProjects);
      await tapText(tester, 'Restore');
      expect(
        find.text('An active project is already called Q4 report'),
        findsOneWidget,
      );
      expect(app.archived.value, hasLength(1));
      await tester.pump(const Duration(seconds: 4));
    });
  });

  group('S29', () {
    setUp(() {
      app.active.value = const [];
      app.archived.value = const [];
    });

    testWidgets('explains projects and counts the inbox', (tester) async {
      await app.pump(tester, go: Routes.projects);
      expect(find.byType(ProjectsEmpty), findsOneWidget);
      expect(find.text('Group tasks into projects'), findsOneWidget);
      expect(find.textContaining('Your 1 inbox task stays'), findsOneWidget);
      expect(find.text('New'), findsNothing);
      expect(find.textContaining('Active ·'), findsNothing);
    });

    testWidgets('Create a project opens S28', (tester) async {
      await app.pump(tester, go: Routes.projects);
      await tapText(tester, 'Create a project');
      expect(
        tester.widget<ProjectFormScreen>(find.byType(ProjectFormScreen)).preset,
        isNull,
      );
    });

    for (final (chip, colour, icon) in [
      ('Work', ProjectColorKey.blue, ProjectIconKey.briefcase),
      ('Home', ProjectColorKey.green, ProjectIconKey.home),
      ('Learning', ProjectColorKey.purple, ProjectIconKey.book),
      ('Travel', ProjectColorKey.pink, ProjectIconKey.plane),
    ]) {
      testWidgets('$chip prefills S28', (tester) async {
        await app.pump(tester, go: Routes.projects);
        await tapText(tester, chip);
        expect(
          tester
              .widget<ProjectFormScreen>(find.byType(ProjectFormScreen))
              .preset,
          (name: chip, color: colour, icon: icon),
        );
        expect(find.text(chip), findsOneWidget);
      });
    }

    testWidgets('with only archived projects, shows the segments', (
      tester,
    ) async {
      app.archived.value = [
        testProject(5, 'Old', archivedAt: DateTime.utc(2026, 9, 2)),
      ];
      await app.pump(tester, go: Routes.projects);
      expect(find.text('Archived · 1'), findsOneWidget);
      expect(find.byType(ProjectsEmpty), findsOneWidget);
    });
  });

  for (final brightness in Brightness.values) {
    testWidgets('lays out at 200% text in ${brightness.name}', (tester) async {
      await app.pump(
        tester,
        go: Routes.projects,
        brightness: brightness,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      await tapText(tester, 'Archived · 1');
      expect(tester.takeException(), isNull);
      app.active.value = const [];
      app.archived.value = const [];
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
