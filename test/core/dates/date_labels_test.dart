import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late DateLabels labels;
  setUpAll(() async {
    await initializeDateFormatting('en');
    labels = DateLabels('en');
  });

  test('date formats', () {
    final d = DateTime(2026, 11, 17);
    expect(labels.date(d), 'Tue, 17 Nov');
    expect(labels.dateLong(d), 'Tue, 17 November');
    expect(labels.weekday(DateTime(2026, 11, 16)), 'Mon');
  });

  test('time from minutes after midnight', () {
    expect(labels.time(600), '10:00 AM');
    expect(labels.time(0), '12:00 AM');
    expect(labels.time(720), '12:00 PM');
    expect(labels.time(1439), '11:59 PM');
  });

  group('daysBetween', () {
    test('ignores the time of day', () {
      expect(
        DateLabels.daysBetween(
          DateTime(2026, 11, 17, 23, 59),
          DateTime(2026, 11, 18, 0, 1),
        ),
        1,
      );
    });

    test('crosses month and year boundaries', () {
      expect(
        DateLabels.daysBetween(DateTime(2026, 11, 17), DateTime(2026, 11, 30)),
        13,
      );
      expect(DateLabels.daysBetween(DateTime(2026, 12, 31), DateTime(2027)), 1);
      expect(
        DateLabels.daysBetween(DateTime(2028, 2, 28), DateTime(2028, 3)),
        2,
      );
    });

    test('is negative for past dates', () {
      expect(
        DateLabels.daysBetween(DateTime(2026, 11, 17), DateTime(2026, 11, 16)),
        -1,
      );
    });

    test('a daylight-saving change does not shift the count', () {
      // Europe and the US change clocks in late March and early November.
      expect(
        DateLabels.daysBetween(DateTime(2026, 3, 28), DateTime(2026, 3, 30)),
        2,
      );
      expect(
        DateLabels.daysBetween(DateTime(2026, 10, 31), DateTime(2026, 11, 2)),
        2,
      );
    });
  });

  test('relativeDay', () {
    final today = DateTime(2027, 1, 1, 15);
    expect(
      DateLabels.relativeDay(DateTime(2026, 12, 31), today),
      RelativeDay.yesterday,
    );
    expect(
      DateLabels.relativeDay(DateTime(2027, 1, 1, 8), today),
      RelativeDay.today,
    );
    expect(
      DateLabels.relativeDay(DateTime(2027, 1, 2), today),
      RelativeDay.tomorrow,
    );
    expect(
      DateLabels.relativeDay(DateTime(2027, 1, 3), today),
      RelativeDay.other,
    );
  });
}
