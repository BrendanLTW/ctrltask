import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/db/stored_dates.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:drift/drift.dart';

extension ProjectRowMapper on ProjectRow {
  Project toEntity() => Project(
    id: id,
    name: name,
    description: description,
    colorKey: ProjectColorKey.values.byName(colorKey),
    iconKey: ProjectIconKey.values.byName(iconKey),
    deadline: deadline == null ? null : localDate(deadline!),
    archivedAt: archivedAt,
    createdAt: createdAt,
    sortOrder: sortOrder,
  );
}

extension ProjectMapper on Project {
  /// The row to update. For a new project, leave out the id.
  ProjectsCompanion toCompanion() => ProjectsCompanion(
    id: Value(id),
    name: Value(name),
    description: Value(description),
    colorKey: Value(colorKey.name),
    iconKey: Value(iconKey.name),
    deadline: Value(deadline == null ? null : storedDate(deadline!)),
    archivedAt: Value(archivedAt),
    createdAt: Value(createdAt),
    sortOrder: Value(sortOrder),
  );
}
