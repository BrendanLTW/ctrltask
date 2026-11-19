import 'package:ctrltask/features/tasks/domain/task_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tasks_providers.g.dart';

/// S19's selected chip. Kept with the app, so Home can open Tasks on a
/// chip (the hero on Today).
@Riverpod(keepAlive: true)
class TasksFilter extends _$TasksFilter {
  @override
  TaskFilter build() => TaskFilter.all;

  TaskFilter get selected => state;
  set selected(TaskFilter filter) => state = filter;
}
