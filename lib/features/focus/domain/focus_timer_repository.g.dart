// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_timer_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with the Drift implementation.

@ProviderFor(focusTimerRepository)
final focusTimerRepositoryProvider = FocusTimerRepositoryProvider._();

/// Overridden in `main.dart` with the Drift implementation.

final class FocusTimerRepositoryProvider
    extends
        $FunctionalProvider<
          FocusTimerRepository,
          FocusTimerRepository,
          FocusTimerRepository
        >
    with $Provider<FocusTimerRepository> {
  /// Overridden in `main.dart` with the Drift implementation.
  FocusTimerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusTimerRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusTimerRepositoryHash();

  @$internal
  @override
  $ProviderElement<FocusTimerRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FocusTimerRepository create(Ref ref) {
    return focusTimerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusTimerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FocusTimerRepository>(value),
    );
  }
}

String _$focusTimerRepositoryHash() =>
    r'45da520fa73d2a6c133956835c322e9c1f983315';
