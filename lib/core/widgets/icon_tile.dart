import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:flutter/material.dart';

/// The icon for a project icon key (DESIGN §8).
AppIcon projectIcon(ProjectIconKey key) => switch (key) {
  ProjectIconKey.globe => AppIcon.globe,
  ProjectIconKey.chart => AppIcon.chart,
  ProjectIconKey.home => AppIcon.home,
  ProjectIconKey.code => AppIcon.code,
  ProjectIconKey.plane => AppIcon.plane,
  ProjectIconKey.briefcase => AppIcon.briefcase,
  ProjectIconKey.bag => AppIcon.bag,
  ProjectIconKey.book => AppIcon.book,
  ProjectIconKey.box => AppIcon.box,
  ProjectIconKey.gift => AppIcon.gift,
  ProjectIconKey.palette => AppIcon.palette,
  ProjectIconKey.heart => AppIcon.heart,
};

/// Icon tile sizes (DESIGN §7).
enum IconTileSize {
  /// 48 × 48, radius 16: project cards and headers.
  large(48, AppRadius.r16, 22),

  /// 40 × 40, radius 13: list rows and the alert banner.
  medium(40, AppRadius.r13, 19),

  /// 28 × 28, radius 9: stat tiles.
  small(28, AppRadius.r9, 15);

  new(this.extent, this.radius, this.iconSize);

  final double extent;
  final double radius;
  final double iconSize;
}

/// A tinted icon tile in a project colour (DESIGN §7). Decorative, so
/// screen readers skip it.
class IconTile extends StatelessWidget {
  const new({
    required this.icon,
    required this.color,
    this.size = IconTileSize.large,
    super.key,
  });

  /// A tile for a project's stored icon key.
  new forProject(
    ProjectIconKey iconKey, {
    required this.color,
    this.size = IconTileSize.large,
    super.key,
  }) : icon = projectIcon(iconKey);

  final AppIcon icon;
  final ProjectColorKey color;
  final IconTileSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.projectColors.of(color);
    return ExcludeSemantics(
      child: Container(
        width: size.extent,
        height: size.extent,
        decoration: BoxDecoration(
          color: colors.tile,
          borderRadius: BorderRadius.circular(size.radius),
        ),
        child: AppIconView(
          icon,
          size: size.iconSize,
          color: colors.icon,
          stroke: AppIconStroke.tile,
        ),
      ),
    );
  }
}
