import 'dart:async';

import 'package:ctrltask/features/data_transfer/domain/backup.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backup_providers.g.dart';

/// The newest backup and what's in it (S42's status box, S35's row).
/// Invalidated after a backup or a restore.
@riverpod
Future<BackupSummary?> backupSummary(Ref ref) =>
    ref.watch(backupStoreProvider).latest();

/// The last failure since the last good backup (S43).
@riverpod
Future<BackupFailure?> backupFailure(Ref ref) =>
    ref.watch(backupStoreProvider).lastFailure();

/// Asks for a backup file anywhere on the phone (Restore → Choose a file);
/// its path, or null if cancelled. Overridden in `main.dart`.
typedef PickBackupFile = Future<String?> Function();

@Riverpod(keepAlive: true)
PickBackupFile pickBackupFile(Ref ref) =>
    throw UnimplementedError('Override pickBackupFileProvider');

/// Keeps the nightly backup booked while Automatic backup is on, from the
/// first launch, not only when S42 is opened. Kept alive by the app.
@Riverpod(keepAlive: true)
class BackupScheduleSync extends _$BackupScheduleSync {
  bool? _booked;

  @override
  void build() {
    ref.listen(preferencesProvider, (_, next) {
      final prefs = next.value;
      if (prefs == null) return;
      final on = prefs.autoBackup && prefs.onboardingComplete;
      if (on == _booked) return;
      _booked = on;
      unawaited(ref.read(backupSchedulerProvider).setNightly(on: on));
    }, fireImmediately: true);
  }
}
