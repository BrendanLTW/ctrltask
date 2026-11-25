// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The newest backup and what's in it (S42's status box, S35's row).
/// Invalidated after a backup or a restore.

@ProviderFor(backupSummary)
final backupSummaryProvider = BackupSummaryProvider._();

/// The newest backup and what's in it (S42's status box, S35's row).
/// Invalidated after a backup or a restore.

final class BackupSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<BackupSummary?>,
          BackupSummary?,
          FutureOr<BackupSummary?>
        >
    with $FutureModifier<BackupSummary?>, $FutureProvider<BackupSummary?> {
  /// The newest backup and what's in it (S42's status box, S35's row).
  /// Invalidated after a backup or a restore.
  BackupSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupSummaryHash();

  @$internal
  @override
  $FutureProviderElement<BackupSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BackupSummary?> create(Ref ref) {
    return backupSummary(ref);
  }
}

String _$backupSummaryHash() => r'9f28b32673dda1aef1563fe4af0f200b62146bf0';

/// The last failure since the last good backup (S43).

@ProviderFor(backupFailure)
final backupFailureProvider = BackupFailureProvider._();

/// The last failure since the last good backup (S43).

final class BackupFailureProvider
    extends
        $FunctionalProvider<
          AsyncValue<BackupFailure?>,
          BackupFailure?,
          FutureOr<BackupFailure?>
        >
    with $FutureModifier<BackupFailure?>, $FutureProvider<BackupFailure?> {
  /// The last failure since the last good backup (S43).
  BackupFailureProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupFailureProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupFailureHash();

  @$internal
  @override
  $FutureProviderElement<BackupFailure?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BackupFailure?> create(Ref ref) {
    return backupFailure(ref);
  }
}

String _$backupFailureHash() => r'f6fe9eee17a2f4dffff6b2e39df3b3520d9a72d3';

@ProviderFor(pickBackupFile)
final pickBackupFileProvider = PickBackupFileProvider._();

final class PickBackupFileProvider
    extends $FunctionalProvider<PickBackupFile, PickBackupFile, PickBackupFile>
    with $Provider<PickBackupFile> {
  PickBackupFileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pickBackupFileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pickBackupFileHash();

  @$internal
  @override
  $ProviderElement<PickBackupFile> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PickBackupFile create(Ref ref) {
    return pickBackupFile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PickBackupFile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PickBackupFile>(value),
    );
  }
}

String _$pickBackupFileHash() => r'8922ae4941abf6e17ecd1c724adfc4f3881e7141';

/// Keeps the nightly backup booked while Automatic backup is on, from the
/// first launch, not only when S42 is opened. Kept alive by the app.

@ProviderFor(BackupScheduleSync)
final backupScheduleSyncProvider = BackupScheduleSyncProvider._();

/// Keeps the nightly backup booked while Automatic backup is on, from the
/// first launch, not only when S42 is opened. Kept alive by the app.
final class BackupScheduleSyncProvider
    extends $NotifierProvider<BackupScheduleSync, void> {
  /// Keeps the nightly backup booked while Automatic backup is on, from the
  /// first launch, not only when S42 is opened. Kept alive by the app.
  BackupScheduleSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupScheduleSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupScheduleSyncHash();

  @$internal
  @override
  BackupScheduleSync create() => BackupScheduleSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$backupScheduleSyncHash() =>
    r'd3f51959080a71d20d43fdeaec633d7406bd677c';

/// Keeps the nightly backup booked while Automatic backup is on, from the
/// first launch, not only when S42 is opened. Kept alive by the app.

abstract class _$BackupScheduleSync extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
