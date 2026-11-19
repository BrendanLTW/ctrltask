// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the user has finished onboarding (stored setting). Null until
/// the settings have loaded; the splash screen waits for it.

@ProviderFor(onboardingComplete)
final onboardingCompleteProvider = OnboardingCompleteProvider._();

/// Whether the user has finished onboarding (stored setting). Null until
/// the settings have loaded; the splash screen waits for it.

final class OnboardingCompleteProvider
    extends $FunctionalProvider<bool?, bool?, bool?>
    with $Provider<bool?> {
  /// Whether the user has finished onboarding (stored setting). Null until
  /// the settings have loaded; the splash screen waits for it.
  OnboardingCompleteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingCompleteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingCompleteHash();

  @$internal
  @override
  $ProviderElement<bool?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool? create(Ref ref) {
    return onboardingComplete(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool?>(value),
    );
  }
}

String _$onboardingCompleteHash() =>
    r'8c2e1ac5a0cebd8e7236fac7f8c046ee9bef9644';

/// The task made on S04, so going back and adding again updates it rather
/// than adding a second one, and S06 can show it.

@ProviderFor(OnboardingFirstTask)
final onboardingFirstTaskProvider = OnboardingFirstTaskProvider._();

/// The task made on S04, so going back and adding again updates it rather
/// than adding a second one, and S06 can show it.
final class OnboardingFirstTaskProvider
    extends $NotifierProvider<OnboardingFirstTask, Task?> {
  /// The task made on S04, so going back and adding again updates it rather
  /// than adding a second one, and S06 can show it.
  OnboardingFirstTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingFirstTaskProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingFirstTaskHash();

  @$internal
  @override
  OnboardingFirstTask create() => OnboardingFirstTask();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Task? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Task?>(value),
    );
  }
}

String _$onboardingFirstTaskHash() =>
    r'493e426c56a089151d4c921189a90ba4b1d3ddba';

/// The task made on S04, so going back and adding again updates it rather
/// than adding a second one, and S06 can show it.

abstract class _$OnboardingFirstTask extends $Notifier<Task?> {
  Task? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Task?, Task?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Task?, Task?>,
              Task?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
