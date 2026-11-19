import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// Whether the user has finished onboarding (stored setting). Null until
/// the settings have loaded; the splash screen waits for it.
@Riverpod(keepAlive: true)
bool? onboardingComplete(Ref ref) =>
    ref.watch(preferencesProvider).value?.onboardingComplete;

/// The task made on S04, so going back and adding again updates it rather
/// than adding a second one, and S06 can show it.
@Riverpod(keepAlive: true)
class OnboardingFirstTask extends _$OnboardingFirstTask {
  @override
  Task? build() => null;

  Task? get task => state;
  set task(Task? value) => state = value;
}
