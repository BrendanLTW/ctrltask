import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/tags/data/drift_tag_repository.dart';
import 'package:ctrltask/features/tags/domain/tag_repository.dart';
import 'package:ctrltask/features/tasks/data/drift_task_repository.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftTagRepository repo;
  late DriftTaskRepository tasks;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftTagRepository(db);
    tasks = DriftTaskRepository(db, () => DateTime(2026, 11, 17, 9, 41));
  });
  tearDown(() => db.close());

  Future<List<(String, int)>> usage() async => [
    for (final u in await repo.watch().first) (u.tag.name, u.taskCount),
  ];

  Future<List<String>> tagsOf(int taskId) async => [
    for (final t in (await tasks.watchDetails(taskId).first)!.tags) t.name,
  ];

  test('create normalises the name and rejects duplicates', () async {
    final tag = await repo.create(' #Design ');
    expect(tag.name, 'design');
    expect(
      () => repo.create('DESIGN'),
      throwsA(isA<DuplicateTagNameException>()),
    );
    expect(() => repo.create('#'), throwsArgumentError);
  });

  test('watch counts tasks, most used first, then by name', () async {
    final work = await repo.create('work');
    final home = await repo.create('home');
    await repo.create('unused');
    await repo.create('admin');
    await tasks.add(TaskDraft(title: 'A', tagIds: {work.id, home.id}));
    await tasks.add(TaskDraft(title: 'B', tagIds: {work.id}));

    expect(await usage(), [
      ('work', 2),
      ('home', 1),
      ('admin', 0),
      ('unused', 0),
    ]);
  });

  test('rename to a free name keeps the tag and its tasks', () async {
    final tag = await repo.create('wrk');
    final task = await tasks.add(TaskDraft(title: 'A', tagIds: {tag.id}));

    final renamed = await repo.rename(tag.id, 'Work');

    expect(renamed.id, tag.id);
    expect(renamed.name, 'work');
    expect(await tagsOf(task.id), ['work']);
  });

  test('rename to an existing name merges the two', () async {
    final work = await repo.create('work');
    final job = await repo.create('job');
    final both = await tasks.add(
      TaskDraft(title: 'Both', tagIds: {work.id, job.id}),
    );
    final jobOnly = await tasks.add(TaskDraft(title: 'Job', tagIds: {job.id}));

    final kept = await repo.rename(job.id, '#Work');

    expect(kept, work);
    expect(await tagsOf(both.id), ['work']);
    expect(await tagsOf(jobOnly.id), ['work']);
    expect(await usage(), [('work', 2)]);
  });

  test('delete takes the tag off every task', () async {
    final tag = await repo.create('later');
    final task = await tasks.add(TaskDraft(title: 'A', tagIds: {tag.id}));

    await repo.delete(tag.id);

    expect(await tagsOf(task.id), isEmpty);
    expect(await usage(), isEmpty);
  });
}
