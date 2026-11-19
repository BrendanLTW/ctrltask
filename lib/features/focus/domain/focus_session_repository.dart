import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'focus_session_repository.g.dart';

/// Focus and break sessions (PRD §5.8, §8).
// shortcut: read-only for Home's Focused tile; task 3.1 adds starting,
// pausing and finishing sessions.
abstract interface class FocusSessionRepository {
  /// Sessions that started on local days [from] to [to], inclusive, oldest
  /// first.
  Stream<List<FocusSession>> watchStartedBetween(DateTime from, DateTime to);

  /// Seconds focused on the project's tasks, counting only focus sessions
  /// that ran at least a minute (S27).
  Stream<int> watchFocusedSeconds(int projectId);
}

/// Overridden in `main.dart` with the Drift implementation.
@Riverpod(keepAlive: true)
FocusSessionRepository focusSessionRepository(Ref ref) =>
    throw UnimplementedError('Override focusSessionRepositoryProvider');
