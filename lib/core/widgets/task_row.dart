import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/widgets/priority_tag.dart';
import 'package:ctrltask/core/widgets/task_content.dart';
import 'package:flutter/material.dart';

/// A task inside a `ListGroup` (Tasks, DESIGN §7): no background of its
/// own, with Urgent and High tags on the right.
class TaskRow extends StatelessWidget {
  const new({
    required this.data,
    required this.onToggle,
    required this.onTap,
    super.key,
  });

  final TaskTileData data;
  final ValueChanged<bool> onToggle;

  /// Opens the task (S12).
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    highlightColor: context.colors.rowPressed,
    splashFactory: NoSplash.splashFactory,
    child: Padding(
      // DESIGN padding 12 18 12 16, less the checkbox's own margin.
      padding: const EdgeInsets.fromLTRB(7, 3, 18, 12),
      child: TaskContent(
        data: data,
        onToggle: onToggle,
        tagInMeta: false,
        trailing: data.showsTag ? PriorityTag(data.priority) : null,
      ),
    ),
  );
}
