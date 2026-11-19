import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/task_link.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S11's Notes & links: saved links, each removable, and Add.
class LinkSection extends StatelessWidget {
  const new({
    required this.links,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });

  final List<TaskLink> links;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l10n.notesLinks),
        ListGroup(
          children: [
            // Laid out by hand so Remove stays its own control for screen
            // readers.
            for (final (i, link) in links.indexed)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 4, 10),
                child: Row(
                  children: [
                    const IconTile(
                      icon: AppIcon.link,
                      color: ProjectColorKey.grey,
                      size: IconTileSize.medium,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            link.title,
                            style: text.rowTitle.copyWith(color: colors.ink),
                          ),
                          Text(
                            link.url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.caption.copyWith(color: colors.muted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => onRemove(i),
                      tooltip: l10n.removeLink,
                      color: colors.muted,
                      icon: const AppIconView(AppIcon.close, size: 18),
                    ),
                  ],
                ),
              ),
            ListGroupRow(
              title: l10n.addNoteOrLink,
              titleColor: colors.muted,
              leading: AppIconView(AppIcon.add, size: 22, color: colors.muted),
              onTap: onAdd,
              chevron: false,
            ),
          ],
        ),
      ],
    );
  }
}
