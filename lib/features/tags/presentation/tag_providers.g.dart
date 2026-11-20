// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every tag with its task count, most used first.

@ProviderFor(tagUsages)
final tagUsagesProvider = TagUsagesProvider._();

/// Every tag with its task count, most used first.

final class TagUsagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TagUsage>>,
          List<TagUsage>,
          Stream<List<TagUsage>>
        >
    with $FutureModifier<List<TagUsage>>, $StreamProvider<List<TagUsage>> {
  /// Every tag with its task count, most used first.
  TagUsagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagUsagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagUsagesHash();

  @$internal
  @override
  $StreamProviderElement<List<TagUsage>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TagUsage>> create(Ref ref) {
    return tagUsages(ref);
  }
}

String _$tagUsagesHash() => r'ddfa62503223d7c2fdc851eea958d756e8d139de';
