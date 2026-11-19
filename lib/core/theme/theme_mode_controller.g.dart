// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Theme setting (S36) as a [ThemeMode]. System by default.
// shortcut: in-memory, resets on restart; task 1.7 reads the stored `theme`
// preference instead.

@ProviderFor(AppThemeMode)
final appThemeModeProvider = AppThemeModeProvider._();

/// The Theme setting (S36) as a [ThemeMode]. System by default.
// shortcut: in-memory, resets on restart; task 1.7 reads the stored `theme`
// preference instead.
final class AppThemeModeProvider
    extends $NotifierProvider<AppThemeMode, ThemeMode> {
  /// The Theme setting (S36) as a [ThemeMode]. System by default.
  // shortcut: in-memory, resets on restart; task 1.7 reads the stored `theme`
  // preference instead.
  AppThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeModeHash();

  @$internal
  @override
  AppThemeMode create() => AppThemeMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$appThemeModeHash() => r'05d2262311525c2b622d8ee79a919e8ff92e2c06';

/// The Theme setting (S36) as a [ThemeMode]. System by default.
// shortcut: in-memory, resets on restart; task 1.7 reads the stored `theme`
// preference instead.

abstract class _$AppThemeMode extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
