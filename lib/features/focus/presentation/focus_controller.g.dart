// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The saved timer, or a fresh focus session before one is saved.

@ProviderFor(savedFocusTimer)
final savedFocusTimerProvider = SavedFocusTimerProvider._();

/// The saved timer, or a fresh focus session before one is saved.

final class SavedFocusTimerProvider
    extends
        $FunctionalProvider<
          AsyncValue<FocusTimer?>,
          FocusTimer?,
          Stream<FocusTimer?>
        >
    with $FutureModifier<FocusTimer?>, $StreamProvider<FocusTimer?> {
  /// The saved timer, or a fresh focus session before one is saved.
  SavedFocusTimerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedFocusTimerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedFocusTimerHash();

  @$internal
  @override
  $StreamProviderElement<FocusTimer?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<FocusTimer?> create(Ref ref) {
    return savedFocusTimer(ref);
  }
}

String _$savedFocusTimerHash() => r'0691f2e2eadfbd03ec83c417ff3a4203985132f6';

/// The focus timer as S30 shows it. An idle timer takes its length from
/// the settings, so a change there shows at once.

@ProviderFor(focusTimer)
final focusTimerProvider = FocusTimerProvider._();

/// The focus timer as S30 shows it. An idle timer takes its length from
/// the settings, so a change there shows at once.

final class FocusTimerProvider
    extends $FunctionalProvider<FocusTimer, FocusTimer, FocusTimer>
    with $Provider<FocusTimer> {
  /// The focus timer as S30 shows it. An idle timer takes its length from
  /// the settings, so a change there shows at once.
  FocusTimerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusTimerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusTimerHash();

  @$internal
  @override
  $ProviderElement<FocusTimer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FocusTimer create(Ref ref) {
    return focusTimer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusTimer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FocusTimer>(value),
    );
  }
}

String _$focusTimerHash() => r'2723d2f02400182ebe9c36967884b894fdc608e5';

/// Runs the focus timer (PRD §5.8, §6.6): every change is saved, and a
/// session that reaches its end is saved and followed by the next phase,
/// whichever screen is open. Kept alive by the app.

@ProviderFor(FocusController)
final focusControllerProvider = FocusControllerProvider._();

/// Runs the focus timer (PRD §5.8, §6.6): every change is saved, and a
/// session that reaches its end is saved and followed by the next phase,
/// whichever screen is open. Kept alive by the app.
final class FocusControllerProvider
    extends $NotifierProvider<FocusController, void> {
  /// Runs the focus timer (PRD §5.8, §6.6): every change is saved, and a
  /// session that reaches its end is saved and followed by the next phase,
  /// whichever screen is open. Kept alive by the app.
  FocusControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusControllerHash();

  @$internal
  @override
  FocusController create() => FocusController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$focusControllerHash() => r'8d79c9ceafcc0233dfc3a2984796e2cb27c750e9';

/// Runs the focus timer (PRD §5.8, §6.6): every change is saved, and a
/// session that reaches its end is saved and followed by the next phase,
/// whichever screen is open. Kept alive by the app.

abstract class _$FocusController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
