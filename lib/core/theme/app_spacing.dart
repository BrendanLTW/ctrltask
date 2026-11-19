/// Spacing tokens from DESIGN §5. Ranged tokens use one value; screens
/// tune them against their designs.
abstract final class AppSpacing {
  /// Left/right margin for cards and rows.
  static const double screenX = 16;

  /// Left/right inset for page titles, section labels and body copy.
  static const double textX = 24;

  /// Between stacked cards (10–12).
  static const double cardGap = 12;

  /// Inside cards (14–22).
  static const double cardPad = 18;

  /// Inside list rows (12–18).
  static const double rowPad = 16;

  /// Space above a section label (10 below it).
  static const double sectionTop = 20;
}
