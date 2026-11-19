import 'package:freezed_annotation/freezed_annotation.dart';

part 'focus_session.freezed.dart';

enum FocusKind { focus, short, long }

/// A focus or break session (PRD §8). Timestamps are UTC.
@freezed
abstract class FocusSession with _$FocusSession {
  const factory({
    required int id,
    required FocusKind kind,
    required int plannedSec,
    required DateTime startedAt,
    required int elapsedSec,
    int? taskId,
    DateTime? endedAt,
    @Default(false) bool completed,
  }) = _FocusSession;
  const new _();

  /// Sessions shorter than a minute don't count toward focus time (§6.6).
  bool get counts => elapsedSec >= 60;
}
