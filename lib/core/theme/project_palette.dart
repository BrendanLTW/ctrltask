import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:flutter/material.dart';

/// `tile` backs icon tiles and tags, `icon` colours their icon and text, and
/// `solid` fills dots, rings, bars and checkbox rings.
typedef ProjectTileColors = ({Color tile, Color icon, Color solid});

/// Project colours per theme (DESIGN §3.4).
/// Read them with `context.projectColors.of(key)`.
@immutable
class ProjectColors extends ThemeExtension<ProjectColors> {
  const new(this.colors);

  static const light = ProjectColors({
    ProjectColorKey.orange: (
      tile: Color(0xFFFFE2B8),
      icon: Color(0xFFC25E00),
      solid: Color(0xFFFB8C00),
    ),
    ProjectColorKey.yellow: (
      tile: Color(0xFFFFF0B8),
      icon: Color(0xFF8A6100),
      solid: Color(0xFFF5B800),
    ),
    ProjectColorKey.green: (
      tile: Color(0xFFC9F3D5),
      icon: Color(0xFF1E8A43),
      solid: Color(0xFF17B26A),
    ),
    ProjectColorKey.blue: (
      tile: Color(0xFFCDE6FB),
      icon: Color(0xFF1769C2),
      solid: Color(0xFF2196F3),
    ),
    ProjectColorKey.purple: (
      tile: Color(0xFFE4DBF7),
      icon: Color(0xFF6D3FD1),
      solid: Color(0xFF7C4DDB),
    ),
    ProjectColorKey.pink: (
      tile: Color(0xFFFBD3E1),
      icon: Color(0xFFC8174F),
      solid: Color(0xFFF0457A),
    ),
    ProjectColorKey.red: (
      tile: Color(0xFFFEE4E2),
      icon: Color(0xFFD92D20),
      solid: Color(0xFFF04438),
    ),
    ProjectColorKey.grey: (
      tile: Color(0xFFEEF1F6),
      icon: Color(0xFF5B6B86),
      solid: Color(0xFF98A2B3),
    ),
  });

  static const dark = ProjectColors({
    ProjectColorKey.orange: (
      tile: Color.fromRGBO(251, 140, 0, 0.20),
      icon: Color(0xFFFFB547),
      solid: Color(0xFFFFB547),
    ),
    ProjectColorKey.yellow: (
      tile: Color.fromRGBO(245, 184, 0, 0.20),
      icon: Color(0xFFFFD34D),
      solid: Color(0xFFFFD34D),
    ),
    ProjectColorKey.green: (
      tile: Color.fromRGBO(23, 178, 106, 0.22),
      icon: Color(0xFF5BD996),
      solid: Color(0xFF47CD89),
    ),
    ProjectColorKey.blue: (
      tile: Color.fromRGBO(33, 150, 243, 0.22),
      icon: Color(0xFF6CB8FF),
      solid: Color(0xFF6CB8FF),
    ),
    ProjectColorKey.purple: (
      tile: Color.fromRGBO(124, 77, 219, 0.26),
      icon: Color(0xFFB69BFF),
      solid: Color(0xFFB69BFF),
    ),
    ProjectColorKey.pink: (
      tile: Color.fromRGBO(240, 69, 122, 0.22),
      icon: Color(0xFFFF7AA2),
      solid: Color(0xFFFF7AA2),
    ),
    ProjectColorKey.red: (
      tile: Color.fromRGBO(240, 68, 56, 0.22),
      icon: Color(0xFFFF8A80),
      solid: Color(0xFFF97066),
    ),
    ProjectColorKey.grey: (
      tile: Color(0xFF232C3A),
      icon: Color(0xFF98A2B3),
      solid: Color(0xFF475467),
    ),
  });

  final Map<ProjectColorKey, ProjectTileColors> colors;

  ProjectTileColors of(ProjectColorKey key) => colors[key]!;

  @override
  ProjectColors copyWith({Map<ProjectColorKey, ProjectTileColors>? colors}) =>
      ProjectColors(colors ?? this.colors);

  @override
  ProjectColors lerp(ProjectColors? other, double t) {
    if (other == null) return this;
    return ProjectColors({
      for (final key in ProjectColorKey.values)
        key: (
          tile: Color.lerp(of(key).tile, other.of(key).tile, t)!,
          icon: Color.lerp(of(key).icon, other.of(key).icon, t)!,
          solid: Color.lerp(of(key).solid, other.of(key).solid, t)!,
        ),
    });
  }
}

extension ProjectColorsContext on BuildContext {
  ProjectColors get projectColors => Theme.of(this).extension<ProjectColors>()!;
}
