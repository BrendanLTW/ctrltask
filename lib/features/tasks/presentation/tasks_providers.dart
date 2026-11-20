import 'package:ctrltask/features/tasks/domain/task_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tasks_providers.g.dart';

/// S19's selected chip. Kept with the app, so Home can open Tasks on a
/// chip (the hero on Today).
/// S19's List or Calendar (S21). Kept with the app, so quick add can tell
/// a calendar day is showing.
enum TasksView { list, calendar }

@Riverpod(keepAlive: true)
class TasksViewMode extends _$TasksViewMode {
  @override
  TasksView build() => TasksView.list;

  TasksView get view => state;
  set view(TasksView value) => state = value;
}

@Riverpod(keepAlive: true)
class TasksFilter extends _$TasksFilter {
  @override
  TaskFilter build() => TaskFilter.all;

  TaskFilter get selected => state;
  set selected(TaskFilter filter) => state = filter;
}
