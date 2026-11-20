import 'package:ctrltask/features/focus/domain/focus_timer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'focus_timer_repository.g.dart';

/// Keeps the focus timer across restarts (PRD §6.6).
abstract interface class FocusTimerRepository {
  /// The saved timer, or null if none has been saved.
  Stream<FocusTimer?> watch();

  Future<void> save(FocusTimer timer);
}

/// Overridden in `main.dart` with the Drift implementation.
@Riverpod(keepAlive: true)
FocusTimerRepository focusTimerRepository(Ref ref) =>
    throw UnimplementedError('Override focusTimerRepositoryProvider');
