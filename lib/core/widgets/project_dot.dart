import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:flutter/material.dart';

/// An 8 px dot in a project's solid colour (DESIGN §7). Decorative: the
/// project's name always sits beside it.
class ProjectDot extends StatelessWidget {
  const new(this.color, {super.key});

  final ProjectColorKey color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.projectColors.of(color).solid,
      ),
    ),
  );
}
