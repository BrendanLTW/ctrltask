import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_session_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_providers.g.dart';

/// The day picked on S21 or S22; today until one is picked. Shared, so
/// the two views and quick add agree.
@Riverpod(keepAlive: true)
class CalendarDay extends _$CalendarDay {
  @override
  DateTime build() {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get day => state;
  set day(DateTime value) =>
      state = DateTime(value.year, value.month, value.day);
}

/// The calendar's Day · Week · Month chips: Month is S21, Day and Week
/// are S22 without or with its week strip.
enum CalendarSpan { day, week, month }

/// Focus sessions started on [day], for S22's timeline.
@riverpod
Stream<List<FocusSession>> focusOn(Ref ref, DateTime day) =>
    ref.watch(focusSessionRepositoryProvider).watchStartedBetween(day, day);
