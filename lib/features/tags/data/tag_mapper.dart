import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/tags/domain/tag.dart';
import 'package:drift/drift.dart';

extension TagRowMapper on TagRow {
  Tag toEntity() => Tag(id: id, name: name);
}

extension TagMapper on Tag {
  /// The row to update. For a new tag, leave out the id.
  TagsCompanion toCompanion() =>
      TagsCompanion(id: Value(id), name: Value(name));
}
