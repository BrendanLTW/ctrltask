import 'dart:io';

import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/data_transfer/data/drift_backup_store.dart';
import 'package:ctrltask/features/data_transfer/domain/backup.dart';
import 'package:ctrltask/features/settings/data/drift_preferences_repository.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

/// The nightly backup's id: Android's unique work name and iOS's
/// `BGTaskSchedulerPermittedIdentifiers` entry (Info.plist, AppDelegate).
const nightlyBackupTask = 'com.brendanltw.ctrltask.backup';

/// Where backups go: the app's Documents/backups, which iOS shows in Files
/// as On My iPhone › ctrlTask (`UIFileSharingEnabled`).
Future<Directory> backupFolder() async => Directory(
  '${(await getApplicationDocumentsDirectory()).path}'
  '${Platform.pathSeparator}backups',
);

/// The next 2 AM, when the phone is usually charging and unused.
Duration untilNightly(DateTime now) {
  final today = DateTime(now.year, now.month, now.day, 2);
  final next = now.isBefore(today)
      ? today
      : DateTime(now.year, now.month, now.day + 1, 2);
  return next.difference(now);
}

/// The background isolate's entry: backs up with its own database
/// connection when Automatic backup is on. A failure is recorded by the
/// store for S43. iOS runs processing tasks once, so it books the next.
@pragma('vm:entry-point')
void backupCallbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    final db = AppDatabase(driftDatabase(name: 'ctrltask'));
    try {
      final prefs = await DriftPreferencesRepository(db).read();
      if (prefs.autoBackup && prefs.onboardingComplete) {
        await DriftBackupStore(
          db,
          backupFolder,
          DateTime.now,
        ).backUp(keep: prefs.backupKeep, automatic: true);
      }
    } on Object {
      // Recorded as the last failure; nothing more to do tonight.
    } finally {
      await db.close();
    }
    if (Platform.isIOS) {
      await WorkmanagerBackupScheduler().setNightly(on: true);
    }
    return true;
  });
}

/// [BackupScheduler] on workmanager: a daily task that needs charging on
/// Android, and a processing task that needs power on iOS (run when iOS
/// allows).
class WorkmanagerBackupScheduler implements BackupScheduler {
  static var _ready = false;

  @override
  Future<void> setNightly({required bool on}) async {
    final workmanager = Workmanager();
    if (!_ready) {
      await workmanager.initialize(backupCallbackDispatcher);
      _ready = true;
    }
    if (!on) return await workmanager.cancelByUniqueName(nightlyBackupTask);
    final constraints = Constraints(
      networkType: NetworkType.notRequired,
      requiresCharging: true,
    );
    final delay = untilNightly(DateTime.now());
    if (Platform.isIOS) {
      return await workmanager.registerProcessingTask(
        nightlyBackupTask,
        nightlyBackupTask,
        initialDelay: delay,
        constraints: constraints,
      );
    }
    return await workmanager.registerPeriodicTask(
      nightlyBackupTask,
      nightlyBackupTask,
      frequency: const Duration(days: 1),
      initialDelay: delay,
      constraints: constraints,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
