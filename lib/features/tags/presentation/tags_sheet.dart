import 'dart:async';

import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/core/widgets/search_field.dart';
import 'package:ctrltask/features/tags/domain/tag.dart';
import 'package:ctrltask/features/tags/domain/tag_repository.dart';
import 'package:ctrltask/features/tags/presentation/tag_providers.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens S18 Tags with [selected] ticked. Resolves to the tags to save, or
/// null if closed.
Future<Set<int>?> showTagsSheet(
  BuildContext context, {
  required Set<int> selected,
}) => showAppSheet<Set<int>>(
  context,
  title: context.l10n.tagsTitle,
  builder: (_) => TagsSheet(selected: selected),
);

/// The name [text] would make, or null if it can't be a tag; the rules of
/// [normaliseTagName].
String? tagNameOrNull(String text) {
  var tag = text.trim();
  if (tag.startsWith('#')) tag = tag.substring(1).trim();
  tag = tag.toLowerCase();
  return tag.isEmpty || tag.length > maxTagNameLength || tag.contains('#')
      ? null
      : tag;
}

/// S18 Tags (PRD §5.5): search or create, the picked tags as chips, and a
/// checklist with how often each is used.
class TagsSheet extends ConsumerStatefulWidget {
  const new({required this.selected, super.key});

  final Set<int> selected;

  @override
  ConsumerState<TagsSheet> createState() => _TagsSheetState();
}

class _TagsSheetState extends ConsumerState<TagsSheet> {
  final _query = TextEditingController();
  late final Set<int> _selected = {...widget.selected};

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _toggle(int id) => setState(
    () => _selected.contains(id) ? _selected.remove(id) : _selected.add(id),
  );

  Future<void> _create(String name) async {
    final repo = ref.read(tagRepositoryProvider);
    try {
      final tag = await repo.create(name);
      if (!mounted) return;
      setState(() {
        _selected.add(tag.id);
        _query.clear();
      });
    } on DuplicateTagNameException {
      // Created meanwhile; the list will show it.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final usages = ref.watch(tagUsagesProvider).value ?? const <TagUsage>[];
    final typed = _query.text.trim();
    final name = tagNameOrNull(typed);
    final search = typed.replaceFirst('#', '').trim().toLowerCase();
    final shown = [
      for (final u in usages)
        if (search.isEmpty || u.tag.name.contains(search)) u,
    ];
    final picked = [
      for (final u in usages)
        if (_selected.contains(u.tag.id)) u.tag,
    ];
    final canCreate = name != null && !usages.any((u) => u.tag.name == name);

    // The list scrolls; search and Save stay put, as the design.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchField(
          controller: _query,
          hint: l10n.searchOrCreateTag,
          icon: AppIcon.tag,
          inSheet: true,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            if (canCreate) unawaited(_create(typed));
          },
        ),
        if (picked.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in picked)
                Semantics(
                  hint: l10n.tapToRemove,
                  child: AppChip(
                    label: l10n.tagLabel(tag.name),
                    selected: true,
                    trailing: AppIconView(
                      AppIcon.close,
                      size: 16,
                      color: colors.onInk,
                    ),
                    onTap: () => _toggle(tag.id),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Flexible(
          child: SingleChildScrollView(
            child: ListGroup(
              inSheet: true,
              children: [
                for (final u in shown)
                  Semantics(
                    checked: _selected.contains(u.tag.id),
                    child: ListGroupRow(
                      title: l10n.tagLabel(u.tag.name),
                      value: '${u.taskCount}',
                      trailing: _Check(on: _selected.contains(u.tag.id)),
                      chevron: false,
                      onTap: () => _toggle(u.tag.id),
                    ),
                  ),
                if (canCreate)
                  ListGroupRow(
                    title: l10n.createTag(name),
                    titleColor: colors.muted,
                    leading: SizedBox(
                      width: 40,
                      child: AppIconView(
                        AppIcon.add,
                        size: 22,
                        color: colors.muted,
                      ),
                    ),
                    chevron: false,
                    onTap: () => unawaited(_create(typed)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: l10n.saveTags(_selected.length),
          onPressed: () => Navigator.of(context).pop({..._selected}),
        ),
      ],
    );
  }
}

/// S18's square tick box.
class _Check extends StatelessWidget {
  const new({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: on ? colors.ink : null,
        borderRadius: BorderRadius.circular(AppRadius.r9),
        border: on ? null : Border.all(color: colors.control, width: 2),
      ),
      child: on
          ? AppIconView(AppIcon.check, size: 16, color: colors.onInk)
          : null,
    );
  }
}
