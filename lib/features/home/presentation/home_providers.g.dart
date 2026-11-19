// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Today's list in display order (PRD §8).

@ProviderFor(todayTasks)
final todayTasksProvider = TodayTasksProvider._();

/// Today's list in display order (PRD §8).

final class TodayTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Task>>,
          List<Task>,
          Stream<List<Task>>
        >
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  /// Today's list in display order (PRD §8).
  TodayTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Task>> create(Ref ref) {
    return todayTasks(ref);
  }
}

String _$todayTasksHash() => r'e34e7385198b9bf121a3f58b0dd3bff95a1556dc';

/// Every open task, for the overdue banner and upcoming deadlines.

@ProviderFor(openTasks)
final openTasksProvider = OpenTasksProvider._();

/// Every open task, for the overdue banner and upcoming deadlines.

final class OpenTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Task>>,
          List<Task>,
          Stream<List<Task>>
        >
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  /// Every open task, for the overdue banner and upcoming deadlines.
  OpenTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Task>> create(Ref ref) {
    return openTasks(ref);
  }
}

String _$openTasksHash() => r'b69ca514de25c89d4e79ec6f483d5a71a081b024';

/// Every done task, for the streak and done this week.

@ProviderFor(doneTasks)
final doneTasksProvider = DoneTasksProvider._();

/// Every done task, for the streak and done this week.

final class DoneTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Task>>,
          List<Task>,
          Stream<List<Task>>
        >
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  /// Every done task, for the streak and done this week.
  DoneTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'doneTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$doneTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Task>> create(Ref ref) {
    return doneTasks(ref);
  }
}

String _$doneTasksHash() => r'a38f8aca6f537aa9f60f02d44efc7f6970b46614';

@ProviderFor(activeProjects)
final activeProjectsProvider = ActiveProjectsProvider._();

final class ActiveProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Project>>,
          List<Project>,
          Stream<List<Project>>
        >
    with $FutureModifier<List<Project>>, $StreamProvider<List<Project>> {
  ActiveProjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeProjectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeProjectsHash();

  @$internal
  @override
  $StreamProviderElement<List<Project>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Project>> create(Ref ref) {
    return activeProjects(ref);
  }
}

String _$activeProjectsHash() => r'a96a378d7acba59d48ffe52c1b16dbdc56cb811a';

@ProviderFor(subtaskProgress)
final subtaskProgressProvider = SubtaskProgressProvider._();

final class SubtaskProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, Progress>>,
          Map<int, Progress>,
          Stream<Map<int, Progress>>
        >
    with
        $FutureModifier<Map<int, Progress>>,
        $StreamProvider<Map<int, Progress>> {
  SubtaskProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subtaskProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subtaskProgressHash();

  @$internal
  @override
  $StreamProviderElement<Map<int, Progress>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<int, Progress>> create(Ref ref) {
    return subtaskProgress(ref);
  }
}

String _$subtaskProgressHash() => r'abd8f6845daf90c2c55da726f526aee82d07704a';

/// Today's focus sessions.

@ProviderFor(focusToday)
final focusTodayProvider = FocusTodayProvider._();

/// Today's focus sessions.

final class FocusTodayProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FocusSession>>,
          List<FocusSession>,
          Stream<List<FocusSession>>
        >
    with
        $FutureModifier<List<FocusSession>>,
        $StreamProvider<List<FocusSession>> {
  /// Today's focus sessions.
  FocusTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusTodayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusTodayHash();

  @$internal
  @override
  $StreamProviderElement<List<FocusSession>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FocusSession>> create(Ref ref) {
    return focusToday(ref);
  }
}

String _$focusTodayHash() => r'40001c696d287f67c36f1fec838ceb962cdda193';
