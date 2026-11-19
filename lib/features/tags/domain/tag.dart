import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';

/// The longest tag name (PRD §8).
const maxTagNameLength = 24;

/// A tag (PRD §8): lowercase, without "#", unique.
@freezed
abstract class Tag with _$Tag {
  const factory({required int id, required String name}) = _Tag;
}

/// A tag name as stored: trimmed, without a leading "#", lowercase.
/// Throws [ArgumentError] if that leaves it blank or over
/// [maxTagNameLength] characters.
String normaliseTagName(String name) {
  var tag = name.trim();
  if (tag.startsWith('#')) tag = tag.substring(1).trim();
  tag = tag.toLowerCase();
  if (tag.isEmpty) throw ArgumentError.value(name, 'name', 'is blank');
  if (tag.length > maxTagNameLength || tag.contains('#')) {
    throw ArgumentError.value(name, 'name', 'not a valid tag name');
  }
  return tag;
}
