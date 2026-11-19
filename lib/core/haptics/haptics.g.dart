// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'haptics.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(haptics)
final hapticsProvider = HapticsProvider._();

final class HapticsProvider
    extends $FunctionalProvider<Haptics, Haptics, Haptics>
    with $Provider<Haptics> {
  HapticsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hapticsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hapticsHash();

  @$internal
  @override
  $ProviderElement<Haptics> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Haptics create(Ref ref) {
    return haptics(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Haptics value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Haptics>(value),
    );
  }
}

String _$hapticsHash() => r'b995e3f836492d40d649c663f2c5944e7790dc7e';
