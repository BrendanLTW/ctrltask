// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every task, archived projects included (PRD §5.7).

@ProviderFor(insightsTasks)
final insightsTasksProvider = InsightsTasksProvider._();

/// Every task, archived projects included (PRD §5.7).

final class InsightsTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Task>>,
          List<Task>,
          Stream<List<Task>>
        >
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  /// Every task, archived projects included (PRD §5.7).
  InsightsTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'insightsTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$insightsTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Task>> create(Ref ref) {
    return insightsTasks(ref);
  }
}

String _$insightsTasksHash() => r'1b91ab2702f14e09aa8ec4a7bd2e26dffa214a76';

/// Focus sessions started on the local days [from] to [to].

@ProviderFor(insightsSessions)
final insightsSessionsProvider = InsightsSessionsFamily._();

/// Focus sessions started on the local days [from] to [to].

final class InsightsSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FocusSession>>,
          List<FocusSession>,
          Stream<List<FocusSession>>
        >
    with
        $FutureModifier<List<FocusSession>>,
        $StreamProvider<List<FocusSession>> {
  /// Focus sessions started on the local days [from] to [to].
  InsightsSessionsProvider._({
    required InsightsSessionsFamily super.from,
    required (DateTime, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'insightsSessionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$insightsSessionsHash();

  @override
  String toString() {
    return r'insightsSessionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<FocusSession>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FocusSession>> create(Ref ref) {
    final argument = this.argument as (DateTime, DateTime);
    return insightsSessions(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is InsightsSessionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$insightsSessionsHash() => r'43d431be305f3326bf82f3ba732df57e789dc9cf';

/// Focus sessions started on the local days [from] to [to].

final class InsightsSessionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<FocusSession>>,
          (DateTime, DateTime)
        > {
  InsightsSessionsFamily._()
    : super(
        retry: null,
        name: r'insightsSessionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Focus sessions started on the local days [from] to [to].

  InsightsSessionsProvider call(DateTime from, DateTime to) =>
      InsightsSessionsProvider._(argument: (from, to), from: this);

  @override
  String toString() => r'insightsSessionsProvider';
}
