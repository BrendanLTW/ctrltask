import 'package:ctrltask/features/projects/domain/project_calculations.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/task_factory.dart';

void main() {
  final today = DateTime(2026, 11, 17);

  test('projectProgress counts done out of every task', () {
    final p = projectProgress([
      task('a', completedAt: DateTime.utc(2026, 11, 10)),
      task('b', completedAt: DateTime.utc(2026, 11, 12)),
      task('c'),
    ]);
    expect(p, (done: 2, total: 3));
    expect(p.percent, 67);
    expect(projectProgress([]).percent, 0);
  });

  test('daysLeft counts calendar days and goes negative', () {
    expect(daysLeft(DateTime(2026, 11, 30), today), 13);
    expect(daysLeft(today, today), 0);
    expect(daysLeft(DateTime(2026, 11, 16), today), -1);
    expect(daysLeft(DateTime(2027), today), 45);
  });

  test('the tag turns red at 7 days or fewer', () {
    expect(deadlineIsClose(8), isFalse);
    expect(deadlineIsClose(7), isTrue);
    expect(deadlineIsClose(0), isTrue);
    expect(deadlineIsClose(-3), isTrue);
  });
}
