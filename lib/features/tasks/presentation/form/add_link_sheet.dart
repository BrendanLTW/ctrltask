import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:ctrltask/core/widgets/app_text_input.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/features/tasks/domain/task_link.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Asks for a link's title and URL (S11 Notes & links). Resolves to the
/// link, or null if closed. The title falls back to the URL.
Future<({String title, String url})?> showAddLinkSheet(BuildContext context) =>
    showAppSheet<({String title, String url})>(
      context,
      title: context.l10n.addLink,
      builder: (_) => const _AddLink(),
    );

class _AddLink extends StatefulWidget {
  const new();

  @override
  State<_AddLink> createState() => _AddLinkState();
}

class _AddLinkState extends State<_AddLink> {
  final _title = TextEditingController();
  late final _url = TextEditingController()..addListener(() => setState(() {}));

  @override
  void dispose() {
    _title.dispose();
    _url.dispose();
    super.dispose();
  }

  bool get _valid => isWebLink(_url.text);

  void _add() {
    if (!_valid) return;
    final url = _url.text.trim();
    final title = _title.text.trim();
    Navigator.of(context).pop((title: title.isEmpty ? url : title, url: url));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typed = _url.text.trim().isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextInput(
          controller: _title,
          maxLength: 80,
          hint: l10n.linkTitleHint,
          autofocus: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        AppTextInput(
          controller: _url,
          maxLength: 500,
          hint: l10n.linkUrlHint,
          textCapitalization: TextCapitalization.none,
          error: typed && !_valid,
          helper: typed && !_valid ? l10n.linkUrlError : null,
          onSubmitted: (_) => _add(),
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: l10n.addLink, onPressed: _valid ? _add : null),
      ],
    );
  }
}
