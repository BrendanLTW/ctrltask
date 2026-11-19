import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/l10n/app_localizations.dart';
import 'package:ctrltask/l10n/date_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  late DateLabels labels;
  setUpAll(() async {
    await initializeDateFormatting('en');
    labels = DateLabels('en');
  });
  final today = DateTime(2026, 11, 17);

  test('dayLabel', () {
    expect(
      l10n.dayLabel(labels, today, today: today, minute: 600),
      'Today, 10:00 AM',
    );
    expect(
      l10n.dayLabel(labels, DateTime(2026, 11, 16), today: today),
      'Yesterday',
    );
    expect(
      l10n.dayLabel(labels, DateTime(2026, 11, 18), today: today),
      'Tomorrow',
    );
    expect(
      l10n.dayLabel(labels, DateTime(2026, 11, 19), today: today, minute: 900),
      'Thu, 19 Nov, 3:00 PM',
    );
  });

  test('overdueLabel', () {
    expect(l10n.overdueLabel(labels, DateTime(2026, 11, 16)), 'Overdue · Mon');
  });

  test('daysLeftLabel', () {
    expect(
      l10n.daysLeftLabel(DateTime(2026, 11, 30), today: today),
      '13 days left',
    );
    expect(
      l10n.daysLeftLabel(DateTime(2026, 11, 18), today: today),
      '1 day left',
    );
  });

  test('durationLabel', () {
    expect(l10n.durationLabel(const Duration(minutes: 75)), '1h 15m');
    expect(l10n.durationLabel(const Duration(hours: 2)), '2h');
    expect(l10n.durationLabel(const Duration(minutes: 25)), '25m');
    expect(l10n.durationLabel(Duration.zero), '0m');
  });
}
