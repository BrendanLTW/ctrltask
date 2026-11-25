import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'features/projects/presentation/projects_app.dart';

/// DESIGN §11 on every v1.0 screen, in both themes: 44 px targets (iOS's
/// guideline; Android's 48 isn't the spec), a label on everything
/// tappable, 4.5:1 text, and no overflow at 200% text.
void main() {
  setUpAll(registerProjectFallbacks);

  ProjectsApp seeded() {
    final app = ProjectsApp();
    app.active.value = [testProject(1, 'Website redesign')];
    app.taskList.value = [
      testTask(1, 'Review wireframes', projectId: 1, dueDate: testNow),
      testTask(2, 'Ship', projectId: 1, done: true),
      testTask(3, 'Call dentist', dueDate: DateTime(2026, 11, 16)),
    ];
    return app;
  }

  Future<void> meetsGuidelines(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  final screens = [
    Routes.home,
    Routes.tasks,
    Routes.projects,
    Routes.focus,
    '/project/1',
    '/task/1',
    Routes.newTask,
    Routes.newProject,
    Routes.search,
    Routes.settings,
    Routes.insights,
    Routes.archivedProjects,
    Routes.tags,
    Routes.notifications,
    Routes.export,
    Routes.theme,
    Routes.weekStart,
    Routes.defaultPriority,
    Routes.editName,
    Routes.backup,
  ];
  final onboarding = [
    Routes.onboarding,
    Routes.onboardingName,
    Routes.onboardingTask,
    Routes.onboardingReminders,
    Routes.onboardingDone,
  ];

  for (final brightness in Brightness.values) {
    group(brightness.name, () {
      for (final route in screens) {
        testWidgets(route, (tester) async {
          final semantics = tester.ensureSemantics();
          await seeded().pump(tester, location: route, brightness: brightness);
          await meetsGuidelines(tester);
          semantics.dispose();
        });

        testWidgets('$route at 200% text', (tester) async {
          await seeded().pump(
            tester,
            location: route,
            brightness: brightness,
            textScale: 2,
          );
          expect(tester.takeException(), isNull);
        });
      }

      for (final route in onboarding) {
        testWidgets(route, (tester) async {
          final semantics = tester.ensureSemantics();
          final app = seeded();
          await app.pump(tester, brightness: brightness);
          await app.container
              .read(preferencesRepositoryProvider)
              .update((p) => p.copyWith(onboardingComplete: false));
          await tester.pumpAndSettle();
          app.router.go(route);
          await tester.pumpAndSettle();
          await meetsGuidelines(tester);

          tester.platformDispatcher.textScaleFactorTestValue = 2;
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '200% text');
          semantics.dispose();
        });
      }

      testWidgets('board', (tester) async {
        final semantics = tester.ensureSemantics();
        await seeded().pump(
          tester,
          location: Routes.tasks,
          brightness: brightness,
        );
        await tester.tap(find.text('Board'));
        await tester.pumpAndSettle();
        await meetsGuidelines(tester);
        semantics.dispose();
      });

      testWidgets('quick add', (tester) async {
        final semantics = tester.ensureSemantics();
        await seeded().pump(tester, brightness: brightness);
        await tester.tap(find.byTooltip('Quick add task'));
        await tester.pumpAndSettle();
        // With the detected-hints line showing.
        await tester.enterText(
          find.byType(EditableText),
          'Call dentist tomorrow 9am !urgent',
        );
        await tester.pumpAndSettle();
        await meetsGuidelines(tester);
        semantics.dispose();
      });
    });
  }
}
