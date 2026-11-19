// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.

@ProviderFor(taskRepository)
final taskRepositoryProvider = TaskRepositoryProvider._();

/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.

final class TaskRepositoryProvider
    extends $FunctionalProvider<TaskRepository, TaskRepository, TaskRepository>
    with $Provider<TaskRepository> {
  /// Overridden in `main.dart` with the Drift implementation, so screens
  /// never import `data/`.
  TaskRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskRepositoryHash();

  @$internal
  @override
  $ProviderElement<TaskRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TaskRepository create(Ref ref) {
    return taskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskRepository>(value),
    );
  }
}

String _$taskRepositoryHash() => r'561d6ba6542f1cf13fb6776406732ea286b78039';
