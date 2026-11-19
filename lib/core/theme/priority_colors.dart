import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:flutter/widgets.dart';

/// The one priority-to-colour mapping (PRD §6.3, DESIGN §3.6), for checkbox
/// rings, tags, filter chips and pickers.
extension PriorityColorKey on TaskPriority {
  ProjectColorKey get colorKey => switch (this) {
    TaskPriority.urgent => ProjectColorKey.red,
    TaskPriority.high => ProjectColorKey.orange,
    TaskPriority.medium => ProjectColorKey.blue,
    TaskPriority.low => ProjectColorKey.grey,
  };
}

extension PriorityColorsContext on BuildContext {
  /// The checkbox ring: the priority's solid colour, except Low, which uses
  /// `control` as the Home design does.
  Color priorityRing(TaskPriority priority) => priority == TaskPriority.low
      ? colors.control
      : projectColors.of(priority.colorKey).solid;
}
