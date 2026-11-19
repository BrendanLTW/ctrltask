import 'package:freezed_annotation/freezed_annotation.dart';

part 'repeat_rule.freezed.dart';

enum RepeatUnit { day, week, month }

/// How a task repeats (PRD §6.4, S15). Every rule may end on [endsOn].
@freezed
sealed class RepeatRule with _$RepeatRule {
  const factory daily({DateTime? endsOn}) = DailyRepeat;

  /// Monday to Friday.
  const factory weekdays({DateTime? endsOn}) = WeekdaysRepeat;

  /// On each of [days], as `DateTime.weekday` values (1 = Monday).
  @Assert('days.isNotEmpty', 'every week needs at least one day')
  @Assert('days.every((d) => d >= 1 && d <= 7)', 'weekday 1–7')
  factory weekly(Set<int> days, {DateTime? endsOn}) = WeeklyRepeat;

  /// On [dayOfMonth]; 29–31 fall back to the month's last day.
  @Assert('dayOfMonth >= 1 && dayOfMonth <= 31', 'day 1–31')
  const factory monthly(int dayOfMonth, {DateTime? endsOn}) = MonthlyRepeat;

  /// Every [interval] days, weeks or months. Months keep aiming for
  /// [dayOfMonth] (the first due date's day), so 31 Jan → 28 Feb → 31 Mar.
  @Assert('interval >= 1 && interval <= 12', 'interval 1–12')
  @Assert(
    'unit != RepeatUnit.month || (dayOfMonth != null && dayOfMonth >= 1 '
        '&& dayOfMonth <= 31)',
    'every N months needs its day 1–31',
  )
  const factory custom(
    int interval,
    RepeatUnit unit, {
    int? dayOfMonth,
    DateTime? endsOn,
  }) = CustomRepeat;
}
