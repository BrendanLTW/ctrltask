// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TasksViewMode)
final tasksViewModeProvider = TasksViewModeProvider._();

final class TasksViewModeProvider
    extends $NotifierProvider<TasksViewMode, TasksView> {
  TasksViewModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksViewModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksViewModeHash();

  @$internal
  @override
  TasksViewMode create() => TasksViewMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TasksView value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TasksView>(value),
    );
  }
}

String _$tasksViewModeHash() => r'aa9ba7b4b9852ec1d8c29b45bd2e6d1c18fdd16b';

abstract class _$TasksViewMode extends $Notifier<TasksView> {
  TasksView build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TasksView, TasksView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TasksView, TasksView>,
              TasksView,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(TasksFilter)
final tasksFilterProvider = TasksFilterProvider._();

final class TasksFilterProvider
    extends $NotifierProvider<TasksFilter, TaskFilter> {
  TasksFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksFilterHash();

  @$internal
  @override
  TasksFilter create() => TasksFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskFilter>(value),
    );
  }
}

String _$tasksFilterHash() => r'5f5da3b59ff04c88d61cc96c699343d2ee85f520';

abstract class _$TasksFilter extends $Notifier<TaskFilter> {
  TaskFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TaskFilter, TaskFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaskFilter, TaskFilter>,
              TaskFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
