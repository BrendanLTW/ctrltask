import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';

/// Field limits from PRD §8 and S28.
const maxProjectNameLength = 40;
const maxProjectDescriptionLength = 300;

/// A project (PRD §8). [deadline] is a local date at midnight; timestamps
/// are UTC. Archived when [archivedAt] is set.
@freezed
abstract class Project with _$Project {
  const factory({
    required int id,
    required String name,
    required ProjectColorKey colorKey,
    required ProjectIconKey iconKey,
    required DateTime createdAt,
    required int sortOrder,
    String? description,
    DateTime? deadline,
    DateTime? archivedAt,
  }) = _Project;
  const new _();

  bool get archived => archivedAt != null;
}
