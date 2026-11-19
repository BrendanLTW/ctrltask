import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/widgets/task_content.dart';
import 'package:flutter/material.dart';

/// A task on its own `surface` card (Home, DESIGN §7).
class TaskCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.r24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        highlightColor: colors.rowPressed,
        splashFactory: NoSplash.splashFactory,
        child: Padding(
          // DESIGN padding 14 16 14 14, less the checkbox's own margin.
          padding: const EdgeInsets.fromLTRB(5, 5, 16, 14),
          child: TaskContent(data: data, onToggle: onToggle),
        ),
      ),
    );
  }
}
