import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_timer.dart';
import 'package:ctrltask/features/focus/domain/focus_timer_repository.dart';
import 'package:drift/drift.dart';

/// The timer in the key-value preferences table, under `focus.timer.*`
/// keys: it's state between taps, not history, so it stays out of the
/// sessions table.
class DriftFocusTimerRepository implements FocusTimerRepository {
  new(this._db);

  final AppDatabase _db;

  static const _prefix = 'focus.timer.';

  @override
  Stream<FocusTimer?> watch() =>
      (_db.select(
        _db.preferences,
      )..where((p) => p.key.like('$_prefix%'))).watch().map(
        (rows) => rows.isEmpty
            ? null
            : _fromValues({
                for (final r in rows) r.key.substring(_prefix.length): r.value,
              }),
      );

  @override
  Future<void> save(FocusTimer timer) => _db.transaction(() async {
    await (_db.delete(
      _db.preferences,
    )..where((p) => p.key.like('$_prefix%'))).go();
    for (final MapEntry(:key, :value) in _toValues(timer).entries) {
      if (value == null) continue;
      await _db
          .into(_db.preferences)
          .insert(
            PreferencesCompanion.insert(key: '$_prefix$key', value: value),
          );
    }
  });

  static Map<String, String?> _toValues(FocusTimer t) => {
    'kind': t.kind.name,
    'phase': t.phase.name,
    'planned': '${t.plannedSec}',
    'task': t.taskId?.toString(),
    'started': t.startedAt?.toUtc().toIso8601String(),
    'running': t.runningSince?.toUtc().toIso8601String(),
    'banked': '${t.bankedSec}',
  };

  /// Unknown or broken values fall back to an idle timer's.
  static FocusTimer _fromValues(Map<String, String> v) {
    DateTime? time(String key) => DateTime.tryParse(v[key] ?? '')?.toUtc();
    final timer = FocusTimer(
      kind: FocusKind.values.asNameMap()[v['kind']] ?? FocusKind.focus,
      phase: TimerPhase.values.asNameMap()[v['phase']] ?? TimerPhase.idle,
      plannedSec: int.tryParse(v['planned'] ?? '') ?? 25 * 60,
      taskId: int.tryParse(v['task'] ?? ''),
      startedAt: time('started'),
      runningSince: time('running'),
      bankedSec: int.tryParse(v['banked'] ?? '') ?? 0,
    );
    // A started phase needs its start; running needs its run.
    final broken =
        (timer.phase != TimerPhase.idle && timer.startedAt == null) ||
        (timer.phase == TimerPhase.running && timer.runningSince == null);
    return broken ? timer.reset() : timer;
  }
}
