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

/// A saved link as S12 shows it: no scheme or `www.`, no trailing slash.
/// "https://www.figma.com/file/x/" reads "figma.com/file/x".
String displayUrl(String url) {
  var shown = url.trim().replaceFirst(
    RegExp('^https?://', caseSensitive: false),
    '',
  );
  shown = shown.replaceFirst(RegExp(r'^www\.', caseSensitive: false), '');
  return shown.endsWith('/') ? shown.substring(0, shown.length - 1) : shown;
}
