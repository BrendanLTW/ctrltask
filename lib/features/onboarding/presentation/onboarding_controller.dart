import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// Whether the user has finished onboarding.
// shortcut: in-memory placeholder, resets on restart; task 2.3 switches it to
// the stored `onboardingComplete` preference.
@Riverpod(keepAlive: true)
class OnboardingComplete extends _$OnboardingComplete {
  @override
  bool build() => false;

  void complete() => state = true;
}
