// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(archivedProjects)
final archivedProjectsProvider = ArchivedProjectsProvider._();

final class ArchivedProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Project>>,
          List<Project>,
          Stream<List<Project>>
        >
    with $FutureModifier<List<Project>>, $StreamProvider<List<Project>> {
  ArchivedProjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archivedProjectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archivedProjectsHash();

  @$internal
  @override
  $StreamProviderElement<List<Project>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Project>> create(Ref ref) {
    return archivedProjects(ref);
  }
}

String _$archivedProjectsHash() => r'844f809c544e18f70db7a1e4c21189331fd77a77';

/// Open and done tasks outside archived projects: S26's progress.

@ProviderFor(allTasks)
final allTasksProvider = AllTasksProvider._();

/// Open and done tasks outside archived projects: S26's progress.

final class AllTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Task>>,
          List<Task>,
          Stream<List<Task>>
        >
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  /// Open and done tasks outside archived projects: S26's progress.
  AllTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Task>> create(Ref ref) {
    return allTasks(ref);
  }
}

String _$allTasksHash() => r'df9eb5ee60729ab092c499b393b5d92b53ac362c';

/// Tasks per project, archived ones included: S45's counts.

@ProviderFor(projectTaskCounts)
final projectTaskCountsProvider = ProjectTaskCountsProvider._();

/// Tasks per project, archived ones included: S45's counts.

final class ProjectTaskCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, int>>,
          Map<int, int>,
          Stream<Map<int, int>>
        >
    with $FutureModifier<Map<int, int>>, $StreamProvider<Map<int, int>> {
  /// Tasks per project, archived ones included: S45's counts.
  ProjectTaskCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectTaskCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectTaskCountsHash();

  @$internal
  @override
  $StreamProviderElement<Map<int, int>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<int, int>> create(Ref ref) {
    return projectTaskCounts(ref);
  }
}

String _$projectTaskCountsHash() => r'1c3dbbd6432b332f05735c619ac010267b422f2c';

@ProviderFor(projectTasks)
final projectTasksProvider = ProjectTasksFamily._();

final class ProjectTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Task>>,
          List<Task>,
          Stream<List<Task>>
        >
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  ProjectTasksProvider._({
    required ProjectTasksFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'projectTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectTasksHash();

  @override
  String toString() {
    return r'projectTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Task>> create(Ref ref) {
    final argument = this.argument as int;
    return projectTasks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectTasksHash() => r'13d2bc6a62303b5e6b604b21dc22914db50520b4';

final class ProjectTasksFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Task>>, int> {
  ProjectTasksFamily._()
    : super(
        retry: null,
        name: r'projectTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProjectTasksProvider call(int projectId) =>
      ProjectTasksProvider._(argument: projectId, from: this);

  @override
  String toString() => r'projectTasksProvider';
}

@ProviderFor(projectFocusedSeconds)
final projectFocusedSecondsProvider = ProjectFocusedSecondsFamily._();

final class ProjectFocusedSecondsProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  ProjectFocusedSecondsProvider._({
    required ProjectFocusedSecondsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'projectFocusedSecondsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectFocusedSecondsHash();

  @override
  String toString() {
    return r'projectFocusedSecondsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as int;
    return projectFocusedSeconds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectFocusedSecondsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectFocusedSecondsHash() =>
    r'35e2a48a4970d971408ec96beb9cc24ef1e5e484';

final class ProjectFocusedSecondsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, int> {
  ProjectFocusedSecondsFamily._()
    : super(
        retry: null,
        name: r'projectFocusedSecondsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProjectFocusedSecondsProvider call(int projectId) =>
      ProjectFocusedSecondsProvider._(argument: projectId, from: this);

  @override
  String toString() => r'projectFocusedSecondsProvider';
}
