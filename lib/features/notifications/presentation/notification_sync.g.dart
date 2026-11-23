// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The one owner of scheduling (PRD §6.5, CLAUDE.md). It plans from the
/// open tasks, settings and focus timer, and reschedules everything when
/// any of them change, on launch and on resume. Completing, archiving or
/// deleting a task drops its reminder because it leaves the plan.

@ProviderFor(NotificationSync)
final notificationSyncProvider = NotificationSyncProvider._();

/// The one owner of scheduling (PRD §6.5, CLAUDE.md). It plans from the
/// open tasks, settings and focus timer, and reschedules everything when
/// any of them change, on launch and on resume. Completing, archiving or
/// deleting a task drops its reminder because it leaves the plan.
final class NotificationSyncProvider
    extends $NotifierProvider<NotificationSync, void> {
  /// The one owner of scheduling (PRD §6.5, CLAUDE.md). It plans from the
  /// open tasks, settings and focus timer, and reschedules everything when
  /// any of them change, on launch and on resume. Completing, archiving or
  /// deleting a task drops its reminder because it leaves the plan.
  NotificationSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSyncHash();

  @$internal
  @override
  NotificationSync create() => NotificationSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$notificationSyncHash() => r'3d29bc3de0d1622f09cfbee2e20b8d0a84ab00e1';

/// The one owner of scheduling (PRD §6.5, CLAUDE.md). It plans from the
/// open tasks, settings and focus timer, and reschedules everything when
/// any of them change, on launch and on resume. Completing, archiving or
/// deleting a task drops its reminder because it leaves the plan.

abstract class _$NotificationSync extends $Notifier<void> {
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
