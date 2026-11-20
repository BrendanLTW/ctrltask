import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/task_link.dart';
import 'package:flutter/material.dart';

/// S12's details group: [rows] above (Repeat), then the saved links;
/// tap a link to open it in the browser.
class LinkRows extends StatelessWidget {
  const new({
    required this.links,
    required this.onOpen,
    this.rows = const [],
    super.key,
  });

  final List<TaskLink> links;
  final ValueChanged<TaskLink> onOpen;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) => ListGroup(
    children: [
      ...rows,
      for (final link in links)
        ListGroupRow(
          title: link.title,
          subtitle: displayUrl(link.url),
          subtitleMaxLines: 1,
          leading: const IconTile(
            icon: AppIcon.link,
            color: ProjectColorKey.purple,
            size: IconTileSize.medium,
          ),
          trailing: const AppIconView(AppIcon.arrowUpRight, size: 20),
          onTap: () => onOpen(link),
          chevron: false,
        ),
    ],
  );
}
