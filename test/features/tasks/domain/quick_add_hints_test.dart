import 'package:ctrltask/features/tasks/domain/quick_add_hints.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Tue 17 Nov 2026.
  final today = DateTime(2026, 11, 17);
  const projects = [
    (id: 1, name: 'Website'),
    (id: 2, name: 'Website redesign'),
    (id: 3, name: 'Q4 report'),
  ];

  QuickAddHints parse(String text) =>
      parseQuickAddHints(text, today: today, projects: projects);

  test('the design example: tomorrow 9 AM', () {
    final h = parse('Call dentist to book cleaning tomorrow 9am');
    expect(h.title, 'Call dentist to book cleaning');
    expect(h.date, DateTime(2026, 11, 18));
    expect(h.minute, 9 * 60);
  });

  group('days', () {
    test('today and tomorrow, any case', () {
      expect(parse('Pay TODAY').date, today);
      expect(parse('Pay Tomorrow').date, DateTime(2026, 11, 18));
    });

    test('a weekday is the next one, as the Saturday chip', () {
      expect(parse('Gym friday').date, DateTime(2026, 11, 20));
      expect(parse('Gym Monday').date, DateTime(2026, 11, 23));
      // Today is Tuesday: next week's.
      expect(parse('Gym tuesday').date, DateTime(2026, 11, 24));
    });

    test('only whole words, and not short forms', () {
      expect(parse('Mondays are long').date, isNull);
      expect(parse('Buy sun cream').date, isNull);
      expect(parse('Todayish').date, isNull);
    });
  });

  group('times', () {
    for (final (text, minute) in [
      ('Call 9am', 9 * 60),
      ('Call 9 AM', 9 * 60),
      ('Call at 9:30pm', 21 * 60 + 30),
      ('Call 12am', 0),
      ('Call 12pm', 12 * 60),
      ('Call 14:30', 14 * 60 + 30),
      ('Call at 07:05', 7 * 60 + 5),
    ]) {
      test(text, () {
        final h = parse(text);
        expect(h.minute, minute);
        expect(h.title, 'Call');
        // A time alone is today.
        expect(h.date, today);
      });
    }

    test('nonsense times are left alone', () {
      for (final text in ['Room 25:00', 'Take 13pm', 'Ratio 1:2:3', 'v2:30x']) {
        final h = parse(text);
        expect(h.minute, isNull, reason: text);
        expect(h.title, text, reason: text);
      }
    });
  });

  test('priority with !', () {
    final h = parse('Ship it !URGENT');
    expect(h.priority, TaskPriority.urgent);
    expect(h.title, 'Ship it');
    expect(parse('Wow!high').priority, isNull, reason: 'needs a space');
    expect(parse('Plan !low').priority, TaskPriority.low);
  });

  test('#tags, once each, any case', () {
    final h = parse('Sketch #design homepage #Design #client-x');
    expect(h.tags, ['design', 'client-x']);
    expect(h.title, 'Sketch homepage');
    expect(parse('Issue#42').tags, isEmpty);
  });

  group('@project', () {
    test('the longest matching name, any case', () {
      final h = parse('Hero copy @website redesign !high');
      expect(h.projectId, 2);
      expect(h.title, 'Hero copy');
      expect(parse('Fix footer @Website').projectId, 1);
      expect(parse('Slides @q4 report tomorrow').projectId, 3);
    });

    test('an @ that names no project stays in the title', () {
      final h = parse('Email @sam about invoices');
      expect(h.projectId, isNull);
      expect(h.title, 'Email @sam about invoices');
      expect(parse('me@website.com').projectId, isNull);
      expect(parse('Ping @Websites').projectId, isNull);
    });
  });

  test('everything at once, in any order', () {
    final h = parse('!urgent #design Review @website redesign friday at 10:00');
    expect(h.title, 'Review');
    expect(h.priority, TaskPriority.urgent);
    expect(h.tags, ['design']);
    expect(h.projectId, 2);
    expect(h.date, DateTime(2026, 11, 20));
    expect(h.minute, 10 * 60);
  });

  test('only hints typed: the title stays as typed', () {
    expect(parse('  tomorrow 9am ').title, 'tomorrow 9am');
  });

  test('nothing detected: spans are empty and the title is tidied', () {
    final h = parse('  Water   the plants ');
    expect(h.spans, isEmpty);
    expect(h.title, 'Water the plants');
  });
}
