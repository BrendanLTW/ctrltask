import 'package:ctrltask/features/tags/domain/tag.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tag_repository.g.dart';

/// A tag and how many tasks use it (S18, S46).
typedef TagUsage = ({Tag tag, int taskCount});

/// A tag with this name already exists.
final class DuplicateTagNameException implements Exception {
  const new(this.name);

  final String name;

  @override
  String toString() => 'DuplicateTagNameException: $name';
}

/// Tags (PRD §5.10, §8). Names go through [normaliseTagName].
abstract interface class TagRepository {
  /// Every tag with its task count, most used first, then by name.
  Stream<List<TagUsage>> watch();

  /// Throws [DuplicateTagNameException].
  Future<Tag> create(String name);

  /// Renames the tag. Renaming to an existing name merges the two (S46);
  /// returns the tag that remains.
  Future<Tag> rename(int id, String name);

  /// Moves every task from [fromId] to [intoId] and deletes [fromId].
  Future<void> merge(int fromId, int intoId);

  /// Deletes the tag and takes it off every task.
  Future<void> delete(int id);
}

/// Overridden in `main.dart` with the Drift implementation.
@Riverpod(keepAlive: true)
TagRepository tagRepository(Ref ref) =>
    throw UnimplementedError('Override tagRepositoryProvider');
