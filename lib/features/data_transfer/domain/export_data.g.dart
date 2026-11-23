// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exportSource)
final exportSourceProvider = ExportSourceProvider._();

final class ExportSourceProvider
    extends $FunctionalProvider<ExportSource, ExportSource, ExportSource>
    with $Provider<ExportSource> {
  ExportSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportSourceHash();

  @$internal
  @override
  $ProviderElement<ExportSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExportSource create(Ref ref) {
    return exportSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExportSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExportSource>(value),
    );
  }
}

String _$exportSourceHash() => r'b381f01c105fa01997c482ad91c6d46e19dc3ca5';
