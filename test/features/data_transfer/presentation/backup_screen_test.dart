import 'dart:io';

import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/app_toggle.dart';
import 'package:ctrltask/features/data_transfer/domain/backup.dart';
import 'package:ctrltask/features/data_transfer/presentation/backup_screen.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../projects/presentation/projects_app.dart';

void main() {
  late ProjectsApp app;

  setUpAll(registerProjectFallbacks);
  setUp(() => app = ProjectsApp());

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  BackupSummary backup(DateTime at) => (
    file: (path: '/backups/${backupFileName(at)}', at: at, bytes: 1258291),
    tasks: 342,
    projects: 8,
  );

  testWidgets('S42 with no backups yet', (tester) async {
    await app.pump(tester, location: Routes.backup);
    for (final text in [
      'No backups yet',
      'Automatic backup',
      'Every night while charging',
      'Files · ctrlTask',
      'Last 7 backups',
      'Back up now',
      'Restore from a backup',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
  });

  testWidgets('Back up now shows the new backup', (tester) async {
    await app.pump(tester, location: Routes.backup);
    await tapText(tester, 'Back up now');
    expect(find.text('Backed up today, 2:14 AM'), findsOneWidget);
    expect(find.text('342 tasks · 8 projects · 1.2\u00a0MB'), findsOneWidget);
  });

  testWidgets('S43: the failure, then Try again', (tester) async {
    app.backupStore.backups.add(backup(DateTime(2026, 11, 15, 2)));
    app.backupStore.failure = (
      at: DateTime(2026, 11, 17, 2),
      reason: BackupFailureReason.other,
      neededBytes: null,
      automatic: true,
    );
    await app.pump(tester, location: Routes.backup);
    expect(find.text("Last night's backup failed"), findsOneWidget);
    expect(
      find.text("The backup couldn't be saved. Last good backup: Sun, 15 Nov."),
      findsOneWidget,
    );
    expect(find.text('Choose another folder'), findsOneWidget);
    await tapText(tester, 'Try again');
    expect(find.text('Backed up today, 2:14 AM'), findsOneWidget);
    expect(find.text('Back up now'), findsOneWidget);
  });

  testWidgets('a full disk says how much to free up', (tester) async {
    app.backupStore.failure = (
      at: DateTime(2026, 11, 17, 10),
      reason: BackupFailureReason.noSpace,
      neededBytes: 1258291,
      automatic: false,
    );
    await app.pump(tester, location: Routes.backup);
    expect(find.text('The last backup failed'), findsOneWidget);
    expect(
      find.text(
        'Not enough space in Files. Free up 1.2\u00a0MB or choose another '
        'folder.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Automatic backup books or cancels the nightly one', (
    tester,
  ) async {
    await app.pump(tester, location: Routes.backup);
    // Booked at launch, as the setting defaults to on.
    expect(app.backupScheduler.calls, [true]);
    await tester.tap(find.byType(AppToggle));
    await tester.pumpAndSettle();
    expect(
      (await app.container.read(preferencesRepositoryProvider).read())
          .autoBackup,
      isFalse,
    );
    expect(app.backupScheduler.calls, [true, false]);
  });

  testWidgets('Keep picks how many to keep', (tester) async {
    await app.pump(tester, location: Routes.backup);
    await tapText(tester, 'Last 7 backups');
    await tapText(tester, 'Last 14 backups');
    expect(find.text('Last 14 backups'), findsOneWidget);
    expect(
      (await app.container.read(preferencesRepositoryProvider).read())
          .backupKeep,
      14,
    );
  });

  testWidgets('Save backups to explains where they are', (tester) async {
    await app.pump(tester, location: Routes.backup);
    await tapText(tester, 'Files · ctrlTask');
    expect(find.textContaining('ctrlTask'), findsWidgets);
    expect(find.text('Cancel'), findsNothing, reason: 'OK only');
    await tapText(tester, 'OK');
  });

  testWidgets('Restore: pick a backup, confirm, restored', (tester) async {
    app.backupStore.backups.add(backup(DateTime(2026, 11, 15, 2)));
    await app.pump(tester, location: Routes.backup);
    await tapText(tester, 'Restore from a backup');
    await tapText(tester, 'Sun, 15 Nov 2026, 2:00 AM');
    expect(find.text('Restore this backup?'), findsOneWidget);
    await tapText(tester, 'Restore');
    expect(app.backupStore.restored.single.at, DateTime(2026, 11, 15, 2));
    expect(
      find.text('Restored the backup from Sun, 15 Nov 2026'),
      findsOneWidget,
    );
    // The toast hides itself after 3.5 s.
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('Restore a chosen file', (tester) async {
    // Sync: real async file work never finishes in a widget test.
    final dir = Directory.systemTemp.createTempSync('restore');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/mine.json')..writeAsStringSync('{}');
    app.pickedFile = file.path;
    await app.pump(tester, location: Routes.backup);
    await tapText(tester, 'Restore from a backup');
    await tapText(tester, 'Choose a file…');
    await tapText(tester, 'Restore');
    expect(app.backupStore.restored.single.path, file.path);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets("a file that can't be restored says why", (tester) async {
    app.backupStore.backups.add(backup(DateTime(2026, 11, 15, 2)));
    app.backupStore.fail = const BackupException(BackupProblem.newer);
    await app.pump(tester, location: Routes.backup);
    await tapText(tester, 'Restore from a backup');
    await tapText(tester, 'Sun, 15 Nov 2026, 2:00 AM');
    await tapText(tester, 'Restore');
    expect(find.text("Can't restore this file"), findsOneWidget);
    expect(
      find.text(
        'This backup is from a newer version of ctrlTask. '
        'Update the app to restore it.',
      ),
      findsOneWidget,
    );
    expect(app.backupStore.restored, isEmpty);
  });

  testWidgets('S35 shows the last backup and opens S42', (tester) async {
    app.backupStore.backups.add(backup(DateTime(2026, 11, 17, 2, 14)));
    await app.pump(tester, location: Routes.settings);
    expect(find.text('Last backup today, 2:14 AM'), findsOneWidget);
    await tapText(tester, 'Backup & restore');
    expect(find.byType(BackupScreen), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('S42 and S43 lay out at 200% in ${brightness.name}', (
      tester,
    ) async {
      app.backupStore.failure = (
        at: DateTime(2026, 11, 17, 2),
        reason: BackupFailureReason.noSpace,
        neededBytes: 1258291,
        automatic: true,
      );
      await app.pump(
        tester,
        location: Routes.backup,
        brightness: brightness,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      await tapText(tester, 'Try again');
      expect(tester.takeException(), isNull);
    });
  }
}
