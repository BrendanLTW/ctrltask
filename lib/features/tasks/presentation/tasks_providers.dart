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

/// S23's sort and filters, for as long as the app is open.
@Riverpod(keepAlive: true)
class TaskListOptions extends _$TaskListOptions {
  @override
  ListOptions build() => defaultListOptions;

  ListOptions get options => state;
  set options(ListOptions value) => state = value;
}

/// S23's choices while the sheet is open; Show applies them.
@riverpod
class FilterSortDraft extends _$FilterSortDraft {
  @override
  ListOptions build() => ref.read(taskListOptionsProvider);

  ListOptions get value => state;
  set value(ListOptions next) => state = next;
}

@Riverpod(keepAlive: true)
class TasksFilter extends _$TasksFilter {
  @override
  TaskFilter build() => TaskFilter.all;

  TaskFilter get selected => state;
  set selected(TaskFilter filter) => state = filter;
}
