import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/features/home/presentation/upcoming_deadlines.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/presentation/task_tile_data.dart';
import 'package:ctrltask/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../helpers/task_factory.dart';

void main() {
  final today = DateTime(2026, 11, 17);
  Project project(int id, String name, DateTime? deadline) => Project(
    id: id,
    name: name,
    colorKey: ProjectColorKey.orange,
    iconKey: ProjectIconKey.chart,
    createdAt: DateTime.utc(2026),
    sortOrder: 0,
    deadline: deadline,
  );

  test('upcoming deadlines: the next three after today, soonest first', () {
    final items = upcomingDeadlines(
      [
        task('today', dueDate: today),
        task('Thu', dueDate: DateTime(2026, 11, 19)),
        task('next month', dueDate: DateTime(2026, 12, 20)),
        task('undated'),
      ],
      [
        project(1, 'Q4 report', DateTime(2026, 11, 23)),
        project(2, 'No deadline', null),
        project(3, 'Past', DateTime(2026, 11, 10)),
      ],
      today,
    );
    expect(
      [for (final i in items) i.task?.title ?? i.project!.name],
      ['Thu', 'Q4 report', 'next month'],
    );
  });

  group('task tile labels', () {
    late AppLocalizations l10n;
    late DateLabels labels;
    setUpAll(() async {
      await initializeDateFormatting('en');
      l10n = lookupAppLocalizations(const Locale('en'));
      labels = DateLabels('en');
    });
    final now = DateTime(2026, 11, 17, 14);

    String? overdue(DateTime due, [int? minute]) => taskTileData(
      task('t', dueDate: due, dueMinute: minute),
      l10n: l10n,
      labels: labels,
      now: now,
      projects: const {},
      subtasks: const {},
    ).overdueLabel;

    test('earlier days read Overdue · weekday', () {
      expect(overdue(DateTime(2026, 11, 16)), 'Overdue · Mon');
    });

    test('a passed time today reads Overdue · time', () {
      expect(overdue(today, 600), 'Overdue · 10:00 AM');
    });

    test('later today is not overdue', () {
      expect(overdue(today, 15 * 60), isNull);
      expect(overdue(today), isNull);
    });
  });
}
