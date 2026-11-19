// Drift check() constraints name their own column, which this lint flags.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

// Row classes end in `Row` so they don't clash with the domain entities.
// Calendar dates (`dueDate`, `deadline`, `endsOn`) are stored as UTC
// midnight with `storedDate`; timestamps are UTC. Enums are stored by name.

/// Projects (PRD §8). Names are unique among active projects, ignoring case.
@DataClassName('ProjectRow')
@TableIndex.sql(
  'CREATE UNIQUE INDEX projects_active_name '
  'ON projects (name COLLATE NOCASE) WHERE archived_at IS NULL',
)
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().check(name.length.isBetweenValues(1, 40))();
  TextColumn get description =>
      text().nullable().check(description.length.isSmallerOrEqualValue(300))();
  TextColumn get colorKey => text().check(
    colorKey.isIn(const [
      'orange',
      'yellow',
      'green',
      'blue',
      'purple',
      'pink',
      'red',
      'grey',
    ]),
  )();
  TextColumn get iconKey => text().check(
    iconKey.isIn(const [
      'globe',
      'chart',
      'home',
      'code',
      'plane',
      'briefcase',
      'bag',
      'book',
      'box',
      'gift',
      'palette',
      'heart',
    ]),
  )();
  DateTimeColumn get deadline => dateTime().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get sortOrder => integer()();
}

/// Repeat rules (PRD §8, `RepeatRule` in core/repeat). `weekdays` is a
/// bitmask, bit 0 = Monday. Custom months keep their anchor day in
/// `dayOfMonth`.
@DataClassName('RepeatRuleRow')
class RepeatRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text().check(
    kind.isIn(const ['daily', 'weekdays', 'weekly', 'monthly', 'custom']),
  )();
  IntColumn get weekdays => integer()
      .withDefault(const Constant(0))
      .check(weekdays.isBetweenValues(0, 127))();
  IntColumn get dayOfMonth =>
      integer().nullable().check(dayOfMonth.isBetweenValues(1, 31))();
  IntColumn get interval =>
      integer().nullable().check(interval.isBetweenValues(1, 12))();
  TextColumn get unit =>
      text().nullable().check(unit.isIn(const ['day', 'week', 'month']))();
  DateTimeColumn get endsOn => dateTime().nullable()();

  @override
  List<String> get customConstraints => [
    "CHECK (kind != 'weekly' OR weekdays > 0)",
    "CHECK (kind != 'monthly' OR day_of_month IS NOT NULL)",
    "CHECK (kind != 'custom' OR (interval IS NOT NULL AND unit IS NOT NULL))",
    "CHECK (unit IS NOT 'month' OR day_of_month IS NOT NULL)",
  ];
}

/// Tasks (PRD §8). `dueMinute` is minutes after local midnight and needs a
/// `dueDate`. `boardColumn` is `done` exactly when `status` is.
@DataClassName('TaskRow')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().check(title.length.isBetweenValues(1, 120))();
  TextColumn get description =>
      text().nullable().check(description.length.isSmallerOrEqualValue(1000))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get dueMinute =>
      integer().nullable().check(dueMinute.isBetweenValues(0, 1439))();
  TextColumn get priority =>
      text().check(priority.isIn(const ['urgent', 'high', 'medium', 'low']))();
  IntColumn get projectId => integer().nullable().references(
    Projects,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get status => text().check(status.isIn(const ['open', 'done']))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get boardColumn =>
      text().check(boardColumn.isIn(const ['todo', 'doing', 'done']))();
  IntColumn get sortOrder => integer()();
  IntColumn get repeatRuleId => integer().nullable().references(
    RepeatRules,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get reminder => text()
      .withDefault(const Constant('none'))
      .check(
        reminder.isIn(const [
          'none',
          'atTime',
          'min10',
          'min30',
          'hour1',
          'morningOf',
          'dayBefore',
        ]),
      )();

  @override
  List<String> get customConstraints => [
    'CHECK (due_minute IS NULL OR due_date IS NOT NULL)',
    "CHECK ((status = 'done') = (board_column = 'done'))",
  ];
}

/// Subtasks (PRD §8), deleted with their task. The 50-per-task limit is
/// enforced by the task repository.
@DataClassName('SubtaskRow')
class Subtasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId =>
      integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().check(title.length.isBetweenValues(1, 120))();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer()();
}

/// Tags (PRD §8): lowercase, no "#", 1–24 characters, unique.
@DataClassName('TagRow')
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name =>
      text().unique().check(name.length.isBetweenValues(1, 24))();

  @override
  List<String> get customConstraints => [
    "CHECK (name = lower(name) AND instr(name, '#') = 0)",
  ];
}

/// A task's tags, removed with either side.
@DataClassName('TaskTagRow')
class TaskTags extends Table {
  IntColumn get taskId =>
      integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {taskId, tagId};
}

/// Saved links on a task (S11, S12), deleted with it. http or https only.
@DataClassName('LinkRow')
class Links extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId =>
      integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get url => text()();

  @override
  List<String> get customConstraints => [
    "CHECK (url LIKE 'http://_%' OR url LIKE 'https://_%')",
  ];
}

/// Focus sessions (PRD §8). Kept when their task is deleted.
@DataClassName('FocusSessionRow')
class FocusSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().nullable().references(
    Tasks,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get kind =>
      text().check(kind.isIn(const ['focus', 'short', 'long']))();
  IntColumn get plannedSec =>
      integer().check(plannedSec.isBiggerThanValue(0))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get elapsedSec =>
      integer().check(elapsedSec.isBiggerOrEqualValue(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

/// Settings as key–value pairs (PRD §8 Preferences).
class Preferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
