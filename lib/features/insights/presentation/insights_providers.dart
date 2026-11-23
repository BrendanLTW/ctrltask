import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_session_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'insights_providers.g.dart';

/// Every task, archived projects included (PRD §5.7).
@riverpod
Stream<List<Task>> insightsTasks(Ref ref) =>
    ref.watch(taskRepositoryProvider).watchForInsights();

/// Focus sessions started on the local days [from] to [to].
@riverpod
Stream<List<FocusSession>> insightsSessions(
  Ref ref,
  DateTime from,
  DateTime to,
) => ref.watch(focusSessionRepositoryProvider).watchStartedBetween(from, to);
