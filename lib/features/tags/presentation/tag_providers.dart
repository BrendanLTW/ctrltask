import 'package:ctrltask/features/tags/domain/tag_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tag_providers.g.dart';

/// Every tag with its task count, most used first.
@riverpod
Stream<List<TagUsage>> tagUsages(Ref ref) =>
    ref.watch(tagRepositoryProvider).watch();
