import 'package:ctrltask/core/repeat/next_occurrence.dart';
import 'package:ctrltask/core/repeat/repeat_rule.dart';
import 'package:flutter_test/flutter_test.dart';

/// Applies [rule] [count] times from [start] and returns every due date.
List<DateTime?> chain(RepeatRule rule, DateTime start, int count) {
  final out = <DateTime?>[];
  DateTime? due = start;
  for (var i = 0; i < count && due != null; i++) {
    due = nextOccurrence(rule, due);
    out.add(due);
  }
  return out;
}

void main() {
  // Tue 17 Nov 2026.
  final tue = DateTime(2026, 11, 17);

  group('daily', () {
    test('is the next day, across a month and a year end', () {
      expect(
        nextOccurrence(const RepeatRule.daily(), tue),
        DateTime(2026, 11, 18),
      );
      expect(
        nextOccurrence(const RepeatRule.daily(), DateTime(2026, 11, 30)),
        DateTime(2026, 12),
      );
      expect(
        nextOccurrence(const RepeatRule.daily(), DateTime(2026, 12, 31)),
        DateTime(2027),
      );
    });

    test('drops the time of day', () {
      expect(
        nextOccurrence(
          const RepeatRule.daily(),
          DateTime(2026, 11, 17, 23, 59),
        ),
        DateTime(2026, 11, 18),
      );
    });
  });

  group('weekdays', () {
    const rule = RepeatRule.weekdays();

    test('Monday to Thursday go to the next day', () {
      expect(
        nextOccurrence(rule, DateTime(2026, 11, 16)),
        DateTime(2026, 11, 17),
      );
      expect(
        nextOccurrence(rule, DateTime(2026, 11, 19)),
        DateTime(2026, 11, 20),
      );
    });

    test('Friday, Saturday and Sunday go to Monday', () {
      for (final day in [20, 21, 22]) {
        expect(
          nextOccurrence(rule, DateTime(2026, 11, day)),
          DateTime(2026, 11, 23),
          reason: 'from $day Nov',
        );
      }
    });
  });

  group('weekly', () {
    test('one day: the same weekday a week later', () {
      expect(
        nextOccurrence(RepeatRule.weekly({DateTime.tuesday}), tue),
        DateTime(2026, 11, 24),
      );
    });

    test('several days: the next chosen day, this week or next', () {
      // S15: "Repeat every Mon, Thu".
      final rule = RepeatRule.weekly({DateTime.monday, DateTime.thursday});
      expect(chain(rule, tue, 4), [
        DateTime(2026, 11, 19),
        DateTime(2026, 11, 23),
        DateTime(2026, 11, 26),
        DateTime(2026, 11, 30),
      ]);
    });

    test('a day earlier in the week wraps to next week', () {
      expect(
        nextOccurrence(RepeatRule.weekly({DateTime.monday}), tue),
        DateTime(2026, 11, 23),
      );
    });

    test('crosses a year end', () {
      expect(
        nextOccurrence(
          RepeatRule.weekly({DateTime.friday}),
          DateTime(2026, 12, 29),
        ),
        DateTime(2027),
      );
    });

    test('needs at least one day', () {
      expect(() => RepeatRule.weekly(<int>{}), throwsA(isA<AssertionError>()));
      expect(() => RepeatRule.weekly({0}), throwsA(isA<AssertionError>()));
    });
  });

  group('monthly', () {
    test('on the 15th: this month if still ahead, else next', () {
      const rule = RepeatRule.monthly(15);
      expect(
        nextOccurrence(rule, DateTime(2026, 11, 10)),
        DateTime(2026, 11, 15),
      );
      expect(
        nextOccurrence(rule, DateTime(2026, 11, 15)),
        DateTime(2026, 12, 15),
      );
      expect(nextOccurrence(rule, tue), DateTime(2026, 12, 15));
      expect(
        nextOccurrence(rule, DateTime(2026, 12, 15)),
        DateTime(2027, 1, 15),
      );
    });

    test('on the 31st falls back to the last day and returns to the 31st', () {
      expect(chain(const RepeatRule.monthly(31), DateTime(2027, 1, 31), 6), [
        DateTime(2027, 2, 28),
        DateTime(2027, 3, 31),
        DateTime(2027, 4, 30),
        DateTime(2027, 5, 31),
        DateTime(2027, 6, 30),
        DateTime(2027, 7, 31),
      ]);
    });

    test('on the 30th in February, leap and non-leap', () {
      const rule = RepeatRule.monthly(30);
      expect(
        nextOccurrence(rule, DateTime(2027, 1, 30)),
        DateTime(2027, 2, 28),
      );
      expect(
        nextOccurrence(rule, DateTime(2028, 1, 30)),
        DateTime(2028, 2, 29),
      );
      expect(
        nextOccurrence(rule, DateTime(2028, 2, 29)),
        DateTime(2028, 3, 30),
      );
    });

    test('on the 29th in February, leap and non-leap', () {
      const rule = RepeatRule.monthly(29);
      expect(
        nextOccurrence(rule, DateTime(2027, 1, 29)),
        DateTime(2027, 2, 28),
      );
      expect(
        nextOccurrence(rule, DateTime(2027, 2, 28)),
        DateTime(2027, 3, 29),
      );
      expect(
        nextOccurrence(rule, DateTime(2028, 1, 29)),
        DateTime(2028, 2, 29),
      );
      expect(
        nextOccurrence(rule, DateTime(2028, 2, 29)),
        DateTime(2028, 3, 29),
      );
    });

    test('a fallback day earlier in the month still moves forward', () {
      // Due 28 Feb under "the 31st": 28 Feb is this month's 31st, so next
      // is March.
      expect(
        nextOccurrence(const RepeatRule.monthly(31), DateTime(2027, 2, 28)),
        DateTime(2027, 3, 31),
      );
    });

    test('rejects days outside 1–31', () {
      expect(() => RepeatRule.monthly(0), throwsA(isA<AssertionError>()));
      expect(() => RepeatRule.monthly(32), throwsA(isA<AssertionError>()));
    });
  });

  group('custom', () {
    test('every 1 and 12 days', () {
      expect(
        nextOccurrence(const RepeatRule.custom(1, RepeatUnit.day), tue),
        DateTime(2026, 11, 18),
      );
      expect(
        nextOccurrence(const RepeatRule.custom(12, RepeatUnit.day), tue),
        DateTime(2026, 11, 29),
      );
      expect(
        nextOccurrence(
          const RepeatRule.custom(12, RepeatUnit.day),
          DateTime(2026, 12, 25),
        ),
        DateTime(2027, 1, 6),
      );
    });

    test('every 1 and 12 weeks', () {
      expect(
        nextOccurrence(const RepeatRule.custom(1, RepeatUnit.week), tue),
        DateTime(2026, 11, 24),
      );
      expect(
        nextOccurrence(const RepeatRule.custom(12, RepeatUnit.week), tue),
        DateTime(2027, 2, 9),
      );
    });

    test('every 1 and 12 months, keeping the anchor day', () {
      expect(
        nextOccurrence(
          const RepeatRule.custom(1, RepeatUnit.month, dayOfMonth: 17),
          tue,
        ),
        DateTime(2026, 12, 17),
      );
      expect(
        nextOccurrence(
          const RepeatRule.custom(12, RepeatUnit.month, dayOfMonth: 17),
          tue,
        ),
        DateTime(2027, 11, 17),
      );
      expect(
        chain(
          const RepeatRule.custom(1, RepeatUnit.month, dayOfMonth: 31),
          DateTime(2027, 1, 31),
          3,
        ),
        [DateTime(2027, 2, 28), DateTime(2027, 3, 31), DateTime(2027, 4, 30)],
      );
    });

    test('every 12 months from 29 Feb lands on 28 Feb, then back', () {
      expect(
        chain(
          const RepeatRule.custom(12, RepeatUnit.month, dayOfMonth: 29),
          DateTime(2028, 2, 29),
          4,
        ),
        [
          DateTime(2029, 2, 28),
          DateTime(2030, 2, 28),
          DateTime(2031, 2, 28),
          DateTime(2032, 2, 29),
        ],
      );
    });

    test('every 3 months crosses a year end', () {
      expect(
        nextOccurrence(
          const RepeatRule.custom(3, RepeatUnit.month, dayOfMonth: 30),
          DateTime(2026, 11, 30),
        ),
        DateTime(2027, 2, 28),
      );
    });

    test('rejects intervals outside 1–12 and months without a day', () {
      expect(
        () => RepeatRule.custom(0, RepeatUnit.day),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => RepeatRule.custom(13, RepeatUnit.week),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => RepeatRule.custom(2, RepeatUnit.month),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('end date', () {
    test('a next date before or on the end date is kept', () {
      expect(
        nextOccurrence(RepeatRule.daily(endsOn: DateTime(2026, 11, 30)), tue),
        DateTime(2026, 11, 18),
      );
      expect(
        nextOccurrence(RepeatRule.daily(endsOn: DateTime(2026, 11, 18)), tue),
        DateTime(2026, 11, 18),
      );
    });

    test('a next date after the end date is none', () {
      expect(nextOccurrence(RepeatRule.daily(endsOn: tue), tue), isNull);
      expect(
        nextOccurrence(
          RepeatRule.monthly(31, endsOn: DateTime(2027, 2, 27)),
          DateTime(2027, 1, 31),
        ),
        isNull,
      );
    });

    test('the end date counts as a whole day, whatever its time', () {
      expect(
        nextOccurrence(
          RepeatRule.daily(endsOn: DateTime(2026, 11, 18, 0, 0, 1)),
          tue,
        ),
        DateTime(2026, 11, 18),
      );
    });

    test('ends a chain', () {
      expect(
        chain(
          RepeatRule.weekly({
            DateTime.monday,
            DateTime.thursday,
          }, endsOn: DateTime(2026, 11, 26)),
          tue,
          5,
        ),
        [
          DateTime(2026, 11, 19),
          DateTime(2026, 11, 23),
          DateTime(2026, 11, 26),
          null,
        ],
      );
    });
  });

  test('daylight-saving changes keep midnight dates', () {
    // Run with TZ=Europe/London: clocks change on 29 Mar and 25 Oct 2026.
    expect(
      nextOccurrence(const RepeatRule.daily(), DateTime(2026, 3, 28)),
      DateTime(2026, 3, 29),
    );
    expect(
      nextOccurrence(const RepeatRule.daily(), DateTime(2026, 3, 29)),
      DateTime(2026, 3, 30),
    );
    expect(
      nextOccurrence(
        const RepeatRule.custom(1, RepeatUnit.week),
        DateTime(2026, 10, 22),
      ),
      DateTime(2026, 10, 29),
    );
    expect(
      nextOccurrence(const RepeatRule.daily(), DateTime(2026, 10, 25))!.hour,
      0,
    );
  });
}
