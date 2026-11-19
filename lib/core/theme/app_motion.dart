import 'package:flutter/widgets.dart';

/// Durations and curves from DESIGN §9. Read them with `AppMotion.of`, which
/// turns every animation off when the phone asks for reduced motion.
@immutable
class AppMotion {
  const new({required this.reduced});

  factory of(BuildContext context) =>
      AppMotion(reduced: MediaQuery.disableAnimationsOf(context));

  final bool reduced;

  Duration _d(int ms) => reduced ? Duration.zero : Duration(milliseconds: ms);

  /// Checkbox fill and spring when a task is completed.
  Duration get complete => _d(350);

  /// Progress ring catching up after a completion.
  Duration get ring => _d(400);

  /// Toast sliding up.
  Duration get toast => _d(300);

  /// Bottom sheet sliding up.
  Duration get sheet => _d(280);

  /// Dialog fade and scale.
  Duration get dialog => _d(200);

  /// Toggle thumb.
  Duration get toggle => _d(200);

  /// How long the completion toast stays, whatever the motion setting.
  static const toastHold = Duration(milliseconds: 3500);

  static const Curve easeOut = Curves.easeOut;
}
