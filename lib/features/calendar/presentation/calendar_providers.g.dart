// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The day picked on S21 or S22; today until one is picked. Shared, so
/// the two views and quick add agree.

@ProviderFor(CalendarDay)
final calendarDayProvider = CalendarDayProvider._();

/// The day picked on S21 or S22; today until one is picked. Shared, so
/// the two views and quick add agree.
final class CalendarDayProvider
    extends $NotifierProvider<CalendarDay, DateTime> {
  /// The day picked on S21 or S22; today until one is picked. Shared, so
  /// the two views and quick add agree.
  CalendarDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarDayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarDayHash();

  @$internal
  @override
  CalendarDay create() => CalendarDay();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$calendarDayHash() => r'7f77e63bda1a35f8a611ca7539a580c852b70553';

/// The day picked on S21 or S22; today until one is picked. Shared, so
/// the two views and quick add agree.

abstract class _$CalendarDay extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Focus sessions started on [day], for S22's timeline.

@ProviderFor(focusOn)
final focusOnProvider = FocusOnFamily._();

/// Focus sessions started on [day], for S22's timeline.

final class FocusOnProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FocusSession>>,
          List<FocusSession>,
          Stream<List<FocusSession>>
        >
    with
        $FutureModifier<List<FocusSession>>,
        $StreamProvider<List<FocusSession>> {
  /// Focus sessions started on [day], for S22's timeline.
  FocusOnProvider._({
    required FocusOnFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'focusOnProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$focusOnHash();

  @override
  String toString() {
    return r'focusOnProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<FocusSession>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FocusSession>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return focusOn(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FocusOnProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$focusOnHash() => r'a9953e0371604a91da3d19f7aa65be6278f35d2b';

/// Focus sessions started on [day], for S22's timeline.

final class FocusOnFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<FocusSession>>, DateTime> {
  FocusOnFamily._()
    : super(
        retry: null,
        name: r'focusOnProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Focus sessions started on [day], for S22's timeline.

  FocusOnProvider call(DateTime day) =>
      FocusOnProvider._(argument: day, from: this);

  @override
  String toString() => r'focusOnProvider';
}
