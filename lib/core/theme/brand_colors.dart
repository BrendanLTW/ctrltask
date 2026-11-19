import 'package:flutter/painting.dart';

/// Brand colours (DESIGN §2). Brand orange appears only in the logo, the
/// app icon and the splash loader; never elsewhere in the UI.
abstract final class BrandColors {
  static const orange = Color(0xFFF26A21);

  /// The wordmark: "ctrl" in grey, "Task" in near-black, or on dark
  /// backgrounds grey and white.
  static const ctrlOnLight = Color(0xFF5D6169);
  static const taskOnLight = Color(0xFF15171C);
  static const ctrlOnDark = Color(0xFF98A2B3);
  static const taskOnDark = Color(0xFFFFFFFF);
}
