// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_searches_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with the Drift implementation.

@ProviderFor(recentSearchesRepository)
final recentSearchesRepositoryProvider = RecentSearchesRepositoryProvider._();

/// Overridden in `main.dart` with the Drift implementation.

final class RecentSearchesRepositoryProvider
    extends
        $FunctionalProvider<
          RecentSearchesRepository,
          RecentSearchesRepository,
          RecentSearchesRepository
        >
    with $Provider<RecentSearchesRepository> {
  /// Overridden in `main.dart` with the Drift implementation.
  RecentSearchesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentSearchesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentSearchesRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecentSearchesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecentSearchesRepository create(Ref ref) {
    return recentSearchesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecentSearchesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecentSearchesRepository>(value),
    );
  }
}

String _$recentSearchesRepositoryHash() =>
    r'004f82f98f2debb0a309648bb77d85045b07ef29';
