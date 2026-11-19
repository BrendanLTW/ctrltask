import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'project_repository.g.dart';

/// An active project already has this name, ignoring case.
final class DuplicateProjectNameException implements Exception {
  const new(this.name);

  final String name;

  @override
  String toString() => 'DuplicateProjectNameException: $name';
}

/// Projects (PRD §5.7, §8). Names and descriptions are trimmed; a blank
/// name or one over [maxProjectNameLength], or a description over
/// [maxProjectDescriptionLength], throws [ArgumentError].
abstract interface class ProjectRepository {
  /// Active projects by `sortOrder`, then name.
  Stream<List<Project>> watchActive();

  /// Archived projects by `sortOrder`, then name.
  Stream<List<Project>> watchArchived();

  /// Adds a project last. Throws [DuplicateProjectNameException].
  Future<Project> add({
    required String name,
    required ProjectColorKey colorKey,
    required ProjectIconKey iconKey,
    String? description,
    DateTime? deadline,
  });

  /// Saves every field. Throws [DuplicateProjectNameException].
  Future<void> update(Project project);

  /// Hides the project and its tasks from lists, pickers and Home.
  Future<void> archive(int id);

  /// Makes an archived project active again, exactly as it was. Throws
  /// [DuplicateProjectNameException] if an active project took its name.
  Future<void> restore(int id);

  /// Deletes the project. Its tasks move to Inbox, or are deleted with
  /// everything attached when [deleteTasks] (PRD §5.7).
  Future<void> delete(int id, {required bool deleteTasks});
}

/// Overridden in `main.dart` with the Drift implementation.
@Riverpod(keepAlive: true)
ProjectRepository projectRepository(Ref ref) =>
    throw UnimplementedError('Override projectRepositoryProvider');
