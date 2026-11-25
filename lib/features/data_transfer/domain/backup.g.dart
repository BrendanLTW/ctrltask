// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with the Drift one.

@ProviderFor(backupStore)
final backupStoreProvider = BackupStoreProvider._();

/// Overridden in `main.dart` with the Drift one.

final class BackupStoreProvider
    extends $FunctionalProvider<BackupStore, BackupStore, BackupStore>
    with $Provider<BackupStore> {
  /// Overridden in `main.dart` with the Drift one.
  BackupStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupStoreHash();

  @$internal
  @override
  $ProviderElement<BackupStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupStore create(Ref ref) {
    return backupStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupStore>(value),
    );
  }
}

String _$backupStoreHash() => r'f6c41f47a0771f8208f20118bcae641923c64c40';

@ProviderFor(backupScheduler)
final backupSchedulerProvider = BackupSchedulerProvider._();

final class BackupSchedulerProvider
    extends
        $FunctionalProvider<BackupScheduler, BackupScheduler, BackupScheduler>
    with $Provider<BackupScheduler> {
  BackupSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupSchedulerHash();

  @$internal
  @override
  $ProviderElement<BackupScheduler> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupScheduler create(Ref ref) {
    return backupScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupScheduler>(value),
    );
  }
}

String _$backupSchedulerHash() => r'7042f2c6842bdcc06c7d9ee4282551816d0af5d5';
