// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_detail_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(taskDetails)
final taskDetailsProvider = TaskDetailsFamily._();

final class TaskDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<TaskDetails?>,
          TaskDetails?,
          Stream<TaskDetails?>
        >
    with $FutureModifier<TaskDetails?>, $StreamProvider<TaskDetails?> {
  TaskDetailsProvider._({
    required TaskDetailsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'taskDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskDetailsHash();

  @override
  String toString() {
    return r'taskDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<TaskDetails?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TaskDetails?> create(Ref ref) {
    final argument = this.argument as int;
    return taskDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskDetailsHash() => r'7bf915103ce1b89403d44a9ded4d8adde34bdd84';

final class TaskDetailsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<TaskDetails?>, int> {
  TaskDetailsFamily._()
    : super(
        retry: null,
        name: r'taskDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TaskDetailsProvider call(int id) =>
      TaskDetailsProvider._(argument: id, from: this);

  @override
  String toString() => r'taskDetailsProvider';
}
