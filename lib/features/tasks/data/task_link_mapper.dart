import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/tasks/domain/task_link.dart';
import 'package:drift/drift.dart';

extension LinkRowMapper on LinkRow {
  TaskLink toEntity() =>
      TaskLink(id: id, taskId: taskId, title: title, url: url);
}

extension TaskLinkMapper on TaskLink {
  /// The row to update. For a new link, leave out the id.
  LinksCompanion toCompanion() => LinksCompanion(
    id: Value(id),
    taskId: Value(taskId),
    title: Value(title),
    url: Value(url),
  );
}
