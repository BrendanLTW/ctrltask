import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_searches_repository.g.dart';

/// S24's recent searches, newest first, kept across restarts.
abstract interface class RecentSearchesRepository {
  /// How many are kept.
  static const keep = 6;

  Stream<List<String>> watch();

  /// Puts [query], trimmed, first; an earlier copy, ignoring case, goes.
  Future<void> add(String query);

  Future<void> clear();
}

/// Overridden in `main.dart` with the Drift implementation.
@Riverpod(keepAlive: true)
RecentSearchesRepository recentSearchesRepository(Ref ref) =>
    throw UnimplementedError('Override recentSearchesRepositoryProvider');
