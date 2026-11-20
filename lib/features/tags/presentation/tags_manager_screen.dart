import 'dart:async';

import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_dialog.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:ctrltask/core/widgets/app_text_input.dart';
import 'package:ctrltask/core/widgets/complete_toast.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/message_box.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/core/widgets/search_field.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/core/widgets/sub_screen_bar.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tags/domain/tag.dart';
import 'package:ctrltask/features/tags/domain/tag_repository.dart';
import 'package:ctrltask/features/tags/presentation/tag_providers.dart';
import 'package:ctrltask/features/tags/presentation/tags_sheet.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _Action { show, rename, delete }

/// S46 Tags (PRD §5.10): search, the tags by use, and per tag Show tasks,
/// Rename (merging into a tag of that name) and Delete.
class TagsManagerScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<TagsManagerScreen> createState() => _TagsManagerState();
}

class _TagsManagerState extends ConsumerState<TagsManagerScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  TagRepository get _repo => ref.read(tagRepositoryProvider);

  Future<void> _add() async {
    final l10n = context.l10n;
    final name = await _askName(
      title: l10n.newTag,
      confirm: l10n.createTagButton,
    );
    if (name == null || !mounted) return;
    try {
      await _repo.create(name);
    } on DuplicateTagNameException {
      if (mounted) {
        showCompleteToast(
          context,
          message: l10n.tagNameTaken(name),
          success: false,
        );
      }
    }
  }

  Future<void> _open(TagUsage usage, List<TagUsage> all) async {
    final l10n = context.l10n;
    final tag = usage.tag;
    final action = await showAppSheet<_Action>(
      context,
      title: l10n.tagLabel(tag.name),
      builder: (context) => ListGroup(
        inSheet: true,
        children: [
          for (final (action, icon, label) in [
            (_Action.show, AppIcon.search, l10n.showTaggedTasks),
            (_Action.rename, AppIcon.tag, l10n.rename),
            (_Action.delete, AppIcon.trash, l10n.deleteTag),
          ])
            ListGroupRow(
              title: label,
              titleColor: action == _Action.delete
                  ? context.colors.negative
                  : null,
              leading: AppIconView(
                icon,
                size: 22,
                color: action == _Action.delete
                    ? context.colors.negative
                    : context.colors.ink,
              ),
              chevron: action != _Action.delete,
              onTap: () => Navigator.of(context).pop(action),
            ),
        ],
      ),
    );
    if (!mounted) return;
    switch (action) {
      case _Action.show:
        unawaited(context.push(Routes.search, extra: '#${tag.name}'));
      case _Action.rename:
        await _rename(tag, all);
      case _Action.delete:
        await _delete(usage);
      case null:
        break;
    }
  }

  Future<void> _rename(Tag tag, List<TagUsage> all) async {
    final l10n = context.l10n;
    final name = await _askName(
      title: l10n.renameTag,
      confirm: l10n.save,
      initial: tag.name,
    );
    if (name == null || name == tag.name || !mounted) return;
    // Renaming to a tag that exists merges the two (S46).
    if (all.any((u) => u.tag.name == name)) {
      final choice = await showAppDialog(
        context,
        icon: AppIcon.tag,
        title: l10n.mergeTagTitle(tag.name, name),
        body: l10n.mergeTagBody(tag.name, name),
        confirmLabel: l10n.mergeTag,
      );
      if (choice != DialogChoice.confirm) return;
    }
    await _repo.rename(tag.id, name);
  }

  Future<void> _delete(TagUsage usage) async {
    final l10n = context.l10n;
    final choice = await showAppDialog(
      context,
      icon: AppIcon.trash,
      title: l10n.deleteTagTitle(usage.tag.name),
      body: l10n.deleteTagBody(usage.taskCount),
      confirmLabel: l10n.deleteTag,
      destructive: true,
    );
    if (choice == DialogChoice.confirm) await _repo.delete(usage.tag.id);
  }

  /// A tag name, or null if closed.
  Future<String?> _askName({
    required String title,
    required String confirm,
    String initial = '',
  }) => showAppSheet<String>(
    context,
    title: title,
    builder: (_) => _NameField(initial: initial, confirm: confirm),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final all = ref.watch(tagUsagesProvider).value ?? const <TagUsage>[];
    final query = _search.text.trim().replaceFirst('#', '').toLowerCase();
    final shown = [
      for (final u in all)
        if (query.isEmpty || u.tag.name.contains(query)) u,
    ];
    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Column(
          children: [
            SubScreenBar(
              title: l10n.tagsTitle,
              actionLabel: l10n.addShort,
              onAction: () => unawaited(_add()),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  8,
                  AppSpacing.screenX,
                  40,
                ),
                children: [
                  if (all.isNotEmpty) ...[
                    SearchField(
                      controller: _search,
                      hint: l10n.searchTagsCount(all.length),
                      onChanged: (_) => setState(() {}),
                    ),
                    SectionHeader(l10n.mostUsed),
                    ListGroup(
                      children: [
                        for (final u in shown)
                          ListGroupRow(
                            title: u.tag.name,
                            value: l10n.tagTaskCount(u.taskCount),
                            leading: const IconTile(
                              icon: AppIcon.tag,
                              color: ProjectColorKey.grey,
                              size: IconTileSize.medium,
                            ),
                            onTap: () => unawaited(_open(u, all)),
                          ),
                      ],
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        l10n.noTagsYet,
                        textAlign: TextAlign.center,
                        style: context.text.body.copyWith(color: colors.muted),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.cardGap),
                  // shortcut: "Type # in quick add to tag a task." joins the
                  // note when quick-add hints arrive (v1.1, FR-20).
                  MessageBox(l10n.tagsNote),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tag's name, with its rules: up to 24 characters, no "#" inside.
class _NameField extends StatefulWidget {
  const new({required this.initial, required this.confirm});

  final String initial;
  final String confirm;

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final _name = TextEditingController(text: widget.initial)
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = tagNameOrNull(_name.text);
    void done() {
      if (name != null) Navigator.of(context).pop(name);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextInput(
          controller: _name,
          maxLength: maxTagNameLength + 1,
          hint: context.l10n.tagNameHint,
          autofocus: true,
          textCapitalization: TextCapitalization.none,
          onSubmitted: (_) => done(),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: widget.confirm,
          onPressed: name == null ? null : done,
        ),
      ],
    );
  }
}
