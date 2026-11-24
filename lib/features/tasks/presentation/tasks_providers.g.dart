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

/// S23's sort and filters, for as long as the app is open.

@ProviderFor(TaskListOptions)
final taskListOptionsProvider = TaskListOptionsProvider._();

/// S23's sort and filters, for as long as the app is open.
final class TaskListOptionsProvider
    extends $NotifierProvider<TaskListOptions, ListOptions> {
  /// S23's sort and filters, for as long as the app is open.
  TaskListOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskListOptionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskListOptionsHash();

  @$internal
  @override
  TaskListOptions create() => TaskListOptions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListOptions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListOptions>(value),
    );
  }
}

String _$taskListOptionsHash() => r'de5253137b345e90eda81a96874303b98cf5eb98';

/// S23's sort and filters, for as long as the app is open.

abstract class _$TaskListOptions extends $Notifier<ListOptions> {
  ListOptions build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ListOptions, ListOptions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ListOptions, ListOptions>,
              ListOptions,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// S23's choices while the sheet is open; Show applies them.

@ProviderFor(FilterSortDraft)
final filterSortDraftProvider = FilterSortDraftProvider._();

/// S23's choices while the sheet is open; Show applies them.
final class FilterSortDraftProvider
    extends $NotifierProvider<FilterSortDraft, ListOptions> {
  /// S23's choices while the sheet is open; Show applies them.
  FilterSortDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filterSortDraftProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filterSortDraftHash();

  @$internal
  @override
  FilterSortDraft create() => FilterSortDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListOptions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListOptions>(value),
    );
  }
}

String _$filterSortDraftHash() => r'5387890acb627c64b63efea31d6c81a848163b77';

/// S23's choices while the sheet is open; Show applies them.

abstract class _$FilterSortDraft extends $Notifier<ListOptions> {
  ListOptions build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ListOptions, ListOptions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ListOptions, ListOptions>,
              ListOptions,
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

/// S20's project: chosen on the board or from Board view on S27, for as
/// long as the app is open. Null until chosen; `(projectId: null)` is the
/// Inbox.

@ProviderFor(BoardProject)
final boardProjectProvider = BoardProjectProvider._();

/// S20's project: chosen on the board or from Board view on S27, for as
/// long as the app is open. Null until chosen; `(projectId: null)` is the
/// Inbox.
final class BoardProjectProvider
    extends $NotifierProvider<BoardProject, ({int? projectId})?> {
  /// S20's project: chosen on the board or from Board view on S27, for as
  /// long as the app is open. Null until chosen; `(projectId: null)` is the
  /// Inbox.
  BoardProjectProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'boardProjectProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$boardProjectHash();

  @$internal
  @override
  BoardProject create() => BoardProject();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({int? projectId})? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<({int? projectId})?>(value),
    );
  }
}

String _$boardProjectHash() => r'cc4d863e2e54c84a2977c70cf092e3db02bf58cd';

/// S20's project: chosen on the board or from Board view on S27, for as
/// long as the app is open. Null until chosen; `(projectId: null)` is the
/// Inbox.

abstract class _$BoardProject extends $Notifier<({int? projectId})?> {
  ({int? projectId})? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<({int? projectId})?, ({int? projectId})?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<({int? projectId})?, ({int? projectId})?>,
              ({int? projectId})?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Every task in [projectId] (the Inbox when null), open and done.

@ProviderFor(boardTasks)
final boardTasksProvider = BoardTasksFamily._();

/// Every task in [projectId] (the Inbox when null), open and done.

final class BoardTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Task>>,
          List<Task>,
          Stream<List<Task>>
        >
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  /// Every task in [projectId] (the Inbox when null), open and done.
  BoardTasksProvider._({
    required BoardTasksFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'boardTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$boardTasksHash();

  @override
  String toString() {
    return r'boardTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Task>> create(Ref ref) {
    final argument = this.argument as int?;
    return boardTasks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BoardTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$boardTasksHash() => r'4905ecf33b68935514d040679a28077f769684ca';

/// Every task in [projectId] (the Inbox when null), open and done.

final class BoardTasksFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Task>>, int?> {
  BoardTasksFamily._()
    : super(
        retry: null,
        name: r'boardTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every task in [projectId] (the Inbox when null), open and done.

  BoardTasksProvider call(int? projectId) =>
      BoardTasksProvider._(argument: projectId, from: this);

  @override
  String toString() => r'boardTasksProvider';
}

/// Each task's tag names, for S20's cards.

@ProviderFor(taskTagNames)
final taskTagNamesProvider = TaskTagNamesProvider._();

/// Each task's tag names, for S20's cards.

final class TaskTagNamesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, List<String>>>,
          Map<int, List<String>>,
          Stream<Map<int, List<String>>>
        >
    with
        $FutureModifier<Map<int, List<String>>>,
        $StreamProvider<Map<int, List<String>>> {
  /// Each task's tag names, for S20's cards.
  TaskTagNamesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskTagNamesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskTagNamesHash();

  @$internal
  @override
  $StreamProviderElement<Map<int, List<String>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<int, List<String>>> create(Ref ref) {
    return taskTagNames(ref);
  }
}

String _$taskTagNamesHash() => r'bf61dd5a3878dcb1106de00ae83a579ce129da68';
