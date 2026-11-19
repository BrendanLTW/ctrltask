// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_session_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with the Drift implementation.

@ProviderFor(focusSessionRepository)
final focusSessionRepositoryProvider = FocusSessionRepositoryProvider._();

/// Overridden in `main.dart` with the Drift implementation.

final class FocusSessionRepositoryProvider
    extends
        $FunctionalProvider<
          FocusSessionRepository,
          FocusSessionRepository,
          FocusSessionRepository
        >
    with $Provider<FocusSessionRepository> {
  /// Overridden in `main.dart` with the Drift implementation.
  FocusSessionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusSessionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusSessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<FocusSessionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FocusSessionRepository create(Ref ref) {
    return focusSessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusSessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FocusSessionRepository>(value),
    );
  }
}

String _$focusSessionRepositoryHash() =>
    r'd47e89b5ee55204e8f4e3774390a53260328ba0f';
