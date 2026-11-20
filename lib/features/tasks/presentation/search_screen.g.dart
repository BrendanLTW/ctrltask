// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tasks matching [query], open and done (PRD §5.6).

@ProviderFor(searchTasks)
final searchTasksProvider = SearchTasksFamily._();

/// Tasks matching [query], open and done (PRD §5.6).

final class SearchTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Task>>,
          List<Task>,
          Stream<List<Task>>
        >
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  /// Tasks matching [query], open and done (PRD §5.6).
  SearchTasksProvider._({
    required SearchTasksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchTasksHash();

  @override
  String toString() {
    return r'searchTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Task>> create(Ref ref) {
    final argument = this.argument as String;
    return searchTasks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchTasksHash() => r'66fad962aa54d26fd20065ac7c317feed01e62a6';

/// Tasks matching [query], open and done (PRD §5.6).

final class SearchTasksFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Task>>, String> {
  SearchTasksFamily._()
    : super(
        retry: null,
        name: r'searchTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Tasks matching [query], open and done (PRD §5.6).

  SearchTasksProvider call(String query) =>
      SearchTasksProvider._(argument: query, from: this);

  @override
  String toString() => r'searchTasksProvider';
}

@ProviderFor(recentSearches)
final recentSearchesProvider = RecentSearchesProvider._();

final class RecentSearchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  RecentSearchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentSearchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentSearchesHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return recentSearches(ref);
  }
}

String _$recentSearchesHash() => r'67ac6a1fbabfc88818c43b3ad7292b3dc141295f';
