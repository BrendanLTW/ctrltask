import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_link.freezed.dart';

/// A saved link on a task (S11, S12): http or https only.
@freezed
abstract class TaskLink with _$TaskLink {
  const factory({
    required int id,
    required int taskId,
    required String title,
    required String url,
  }) = _TaskLink;
}

/// Whether [url] is a link a task may save: http or https with a host
/// (PRD §8).
bool isWebLink(String url) {
  final uri = Uri.tryParse(url.trim());
  return uri != null &&
      (uri.isScheme('http') || uri.isScheme('https')) &&
      uri.host.isNotEmpty;
}
