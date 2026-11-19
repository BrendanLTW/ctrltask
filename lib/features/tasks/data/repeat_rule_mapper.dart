import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/db/stored_dates.dart';
import 'package:ctrltask/core/repeat/repeat_rule.dart';
import 'package:drift/drift.dart';

extension RepeatRuleRowMapper on RepeatRuleRow {
  RepeatRule toEntity() {
    final ends = endsOn == null ? null : localDate(endsOn!);
    return switch (kind) {
      'daily' => RepeatRule.daily(endsOn: ends),
      'weekdays' => RepeatRule.weekdays(endsOn: ends),
      'weekly' => RepeatRule.weekly(_daysOf(weekdays), endsOn: ends),
      'monthly' => RepeatRule.monthly(dayOfMonth!, endsOn: ends),
      'custom' => RepeatRule.custom(
        interval!,
        RepeatUnit.values.byName(unit!),
        dayOfMonth: dayOfMonth,
        endsOn: ends,
      ),
      _ => throw StateError('unknown repeat kind: $kind'),
    };
  }
}

extension RepeatRuleMapper on RepeatRule {
  /// A new row for this rule; tasks point at it by id.
  RepeatRulesCompanion toCompanion() {
    final ends = Value(endsOn == null ? null : storedDate(endsOn!));
    return switch (this) {
      DailyRepeat() => RepeatRulesCompanion.insert(kind: 'daily', endsOn: ends),
      WeekdaysRepeat() => RepeatRulesCompanion.insert(
        kind: 'weekdays',
        endsOn: ends,
      ),
      WeeklyRepeat(:final days) => RepeatRulesCompanion.insert(
        kind: 'weekly',
        weekdays: Value(_maskOf(days)),
        endsOn: ends,
      ),
      MonthlyRepeat(:final dayOfMonth) => RepeatRulesCompanion.insert(
        kind: 'monthly',
        dayOfMonth: Value(dayOfMonth),
        endsOn: ends,
      ),
      CustomRepeat(:final interval, :final unit, :final dayOfMonth) =>
        RepeatRulesCompanion.insert(
          kind: 'custom',
          interval: Value(interval),
          unit: Value(unit.name),
          dayOfMonth: Value(dayOfMonth),
          endsOn: ends,
        ),
    };
  }
}

// Bit 0 is Monday (DateTime.monday = 1), bit 6 Sunday.
int _maskOf(Set<int> weekdays) =>
    weekdays.fold(0, (mask, day) => mask | 1 << (day - 1));

Set<int> _daysOf(int mask) => {
  for (var day = 1; day <= 7; day++)
    if (mask & 1 << (day - 1) != 0) day,
};
