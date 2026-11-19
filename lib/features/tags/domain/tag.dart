import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';

/// The longest tag name (PRD §8).
const maxTagNameLength = 24;

/// A tag (PRD §8): lowercase, without "#", unique.
@freezed
abstract class Tag with _$Tag {
  const factory({required int id, required String name}) = _Tag;
}
