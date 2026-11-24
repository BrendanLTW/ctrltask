import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/widgets/name_avatar.dart';
import 'package:ctrltask/features/home/presentation/home_screen.dart';
import 'package:ctrltask/features/projects/presentation/archived_projects.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/settings/presentation/edit_name_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../projects/presentation/projects_app.dart';

void main() {
  late ProjectsApp app;

  setUpAll(registerProjectFallbacks);

  setUp(() {
    app = ProjectsApp();
    app.archived.value = [
      testProject(5, 'Moving house', archivedAt: DateTime.utc(2026, 9, 2)),
      testProject(6, 'Wedding gifts', archivedAt: DateTime.utc(2026, 7, 18)),
    ];
    // Done today, yesterday and the day before: a 3-day streak.
    app.taskList.value = [
      for (final (i, day) in [17, 16, 15].indexed)
        testTask(
          i + 1,
          'Done $i',
          done: true,
        ).copyWith(completedAt: DateTime(2026, 11, day, 8).toUtc()),
      testTask(9, 'Open'),
    ];
  });

  Future<void> pump(WidgetTester tester, {String name = 'Alex'}) async {
    await app.pump(tester);
    await app.container
        .read(preferencesRepositoryProvider)
        .update((p) => p.copyWith(userName: name));
    app.router.push(Routes.settings).ignore();
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  group('S35', () {
    testWidgets('shows the name card, insights and what exists', (
      tester,
    ) async {
      await pump(tester);
      for (final text in [
        'Settings',
        'Alex',
        'Data stored on this phone · Edit name',
        'PRODUCTIVITY INSIGHTS',
        '3-day streak · 3 tasks done',
        'PREFERENCES',
        'Theme',
        'System',
        'Week starts on',
        'Monday',
        'Default priority',
        'Medium',
        'Default focus length',
        'Notifications',
        '4 on',
        '25 min',
        'MANAGE',
        'Archived projects',
        '2',
        'Tags',
        'Export data',
        'CSV or JSON',
        'DATA',
        'Erase all data',
        'ctrlTask 1.0 · by BrendanLTW',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      // Hidden: v1.1.
      expect(find.text('Backup & restore'), findsNothing);
    });

    testWidgets('without a name, offers to add one', (tester) async {
      await pump(tester, name: '');
      expect(find.text('Add your name'), findsOneWidget);
    });

    testWidgets('the banner updates live and opens Insights', (tester) async {
      await pump(tester);
      app.taskList.value = [
        ...app.taskList.value,
        testTask(
          10,
          'Another',
          done: true,
        ).copyWith(completedAt: DateTime(2026, 11, 17, 9).toUtc()),
      ];
      await tester.pumpAndSettle();
      expect(find.text('3-day streak · 4 tasks done'), findsOneWidget);
      await tapText(tester, 'PRODUCTIVITY INSIGHTS');
      expect(find.text('Insights'), findsWidgets);
    });

    testWidgets('Archived projects opens S45', (tester) async {
      await pump(tester);
      await tapText(tester, 'Archived projects');
      expect(find.byType(ArchivedProjectsScreen), findsOneWidget);
    });
  });

  group('S40', () {
    testWidgets('saves a trimmed name, and Home greets it', (tester) async {
      await pump(tester);
      await tapText(tester, 'Alex');
      expect(find.byType(EditNameScreen), findsOneWidget);
      expect(find.text('Alex'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '  Sam  ');
      await tester.pump();
      // The avatar follows the field.
      expect(
        find.descendant(of: find.byType(NameAvatar), matching: find.text('S')),
        findsOneWidget,
      );
      await tapText(tester, 'Save');
      expect(
        (await app.container.read(preferencesRepositoryProvider).read())
            .userName,
        'Sam',
      );
      expect(find.text('Sam'), findsOneWidget, reason: 'back on S35');

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.textContaining('Sam'), findsWidgets);
    });

    testWidgets('Save waits for a name', (tester) async {
      await pump(tester);
      await tapText(tester, 'Alex');
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      await tapText(tester, 'Save');
      expect(find.byType(EditNameScreen), findsOneWidget);
    });

    testWidgets('Cancel keeps the old name', (tester) async {
      await pump(tester);
      await tapText(tester, 'Alex');
      await tester.enterText(find.byType(TextField), 'Sam');
      await tapText(tester, 'Cancel');
      expect(
        (await app.container.read(preferencesRepositoryProvider).read())
            .userName,
        'Alex',
      );
    });
  });

  for (final (brightness, colors) in [
    (Brightness.light, AppColors.light),
    (Brightness.dark, AppColors.dark),
  ]) {
    testWidgets('the insights banner is a hero card in ${brightness.name}', (
      tester,
    ) async {
      await app.pump(tester, brightness: brightness);
      app.router.push(Routes.settings).ignore();
      await tester.pumpAndSettle();
      final banner = find.ancestor(
        of: find.text('PRODUCTIVITY INSIGHTS'),
        matching: find.byType(Material),
      );
      expect(tester.widget<Material>(banner.first).color, colors.hero);
      expect(
        tester.widget<Text>(find.textContaining('-day streak')).style?.color,
        colors.onHero,
      );
    });
  }

  for (final brightness in Brightness.values) {
    testWidgets('lays out at 200% text in ${brightness.name}', (tester) async {
      await app.pump(tester, brightness: brightness, textScale: 2);
      app.router.push(Routes.settings).ignore();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      app.router.push(Routes.editName).ignore();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
