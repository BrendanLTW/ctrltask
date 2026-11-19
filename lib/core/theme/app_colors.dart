import 'package:flutter/material.dart';

/// Colour tokens from DESIGN §3.1–3.3. Read them with `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const new({
    required this.ground,
    required this.surface,
    required this.raised,
    required this.ink,
    required this.onInk,
    required this.inkPressed,
    required this.muted,
    required this.positive,
    required this.negative,
    required this.warning,
    required this.hero,
    required this.heroTrack,
    required this.divider,
    required this.fillSoft,
    required this.control,
    required this.buttonDisabled,
    required this.onButtonDisabled,
    required this.disabled,
    required this.chipText,
    required this.navSelected,
    required this.rowPressed,
    required this.scrim,
    required this.destructive,
    required this.onDestructive,
    required this.errorBox,
    required this.onErrorBox,
    required this.warningBox,
    required this.onWarningBox,
    required this.successBox,
    required this.onSuccessBox,
    required this.infoBox,
    required this.onInfoBox,
  });

  static const light = AppColors(
    ground: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFEEF1F6),
    ink: Color(0xFF101828),
    onInk: Color(0xFFFFFFFF),
    inkPressed: Color(0xFF1D2939),
    muted: Color(0xFF5B6B86),
    positive: Color(0xFF067647),
    negative: Color(0xFFD92D20),
    warning: Color(0xFFB54708),
    hero: Color(0xFF101828),
    heroTrack: Color(0xFF475467),
    divider: Color(0xFFEEF1F6),
    fillSoft: Color(0xFFF2F4F7),
    control: Color(0xFFD0D5DD),
    buttonDisabled: Color(0xFFD0D5DD),
    onButtonDisabled: Color(0xFFFFFFFF),
    disabled: Color(0xFF98A2B3),
    chipText: Color(0xFF344054),
    navSelected: Color(0xFFEEF1F6),
    rowPressed: Color(0xFFFAFBFC),
    scrim: Color(0x6B101828),
    destructive: Color(0xFFD92D20),
    onDestructive: Color(0xFFFFFFFF),
    errorBox: Color(0xFFFEE4E2),
    onErrorBox: Color(0xFFB42318),
    warningBox: Color(0xFFFEF0C7),
    onWarningBox: Color(0xFF93370D),
    successBox: Color(0xFFC9F3D5),
    onSuccessBox: Color(0xFF05603A),
    infoBox: Color(0xFFEEF1F6),
    onInfoBox: Color(0xFF344054),
  );

  static const dark = AppColors(
    ground: Color(0xFF0B1018),
    surface: Color(0xFF161D29),
    raised: Color(0xFF232C3A),
    ink: Color(0xFFF2F4F7),
    onInk: Color(0xFF0B1018),
    inkPressed: Color(0xFFD0D5DD),
    muted: Color(0xFF98A2B3),
    positive: Color(0xFF47CD89),
    negative: Color(0xFFF97066),
    warning: Color(0xFFFDB022),
    hero: Color(0xFF1C2536),
    heroTrack: Color(0xFF344054),
    divider: Color(0xFF232C3A),
    fillSoft: Color(0xFF232C3A),
    control: Color(0xFF475467),
    buttonDisabled: Color(0xFF2A3444),
    onButtonDisabled: Color(0xFF667085),
    disabled: Color(0xFF667085),
    chipText: Color(0xFFD0D5DD),
    navSelected: Color(0xFF2A3444),
    rowPressed: Color(0xFF1B2331),
    scrim: Color(0x99000000),
    destructive: Color(0xFFF04438),
    onDestructive: Color(0xFFFFFFFF),
    errorBox: Color(0x29F04438),
    onErrorBox: Color(0xFFFDA29B),
    warningBox: Color(0x29F79009),
    onWarningBox: Color(0xFFFEC84B),
    successBox: Color(0x2917B26A),
    onSuccessBox: Color(0xFF75E0A7),
    infoBox: Color(0xFF232C3A),
    onInfoBox: Color(0xFFD0D5DD),
  );

  /// Screen background.
  final Color ground;

  /// Cards, rows, list groups, chips, fields, sheets, dialogs, nav bar.
  final Color surface;

  /// Icon buttons, empty-state circles, progress tracks, soft pills.
  final Color raised;

  /// Primary text and primary accent.
  final Color ink;

  /// Text and icons on ink fills.
  final Color onInk;

  /// Pressed state of ink fills.
  final Color inkPressed;

  /// Secondary text, captions, labels, unselected segments, done titles.
  final Color muted;

  /// Success, "Backed up", positive changes.
  final Color positive;

  /// Overdue dates, destructive actions, error outlines.
  final Color negative;

  /// Warnings.
  final Color warning;

  /// Progress hero, insights banner, splash and welcome panels.
  final Color hero;

  /// Ring and bar track on the hero.
  final Color heroTrack;

  /// Lines between rows in a list group, timeline rails.
  final Color divider;

  /// Small chips, steppers, segmented track and rows inside sheets.
  final Color fillSoft;

  /// Toggle off, radio border, today ring in the calendar.
  final Color control;

  /// Disabled primary button fill.
  final Color buttonDisabled;

  /// The disabled primary button's label.
  final Color onButtonDisabled;

  /// Past dates, placeholders, disabled text.
  final Color disabled;

  /// Unselected chip label, tag chip label, text in tinted boxes.
  final Color chipText;

  /// Active tab pill in the bottom bar.
  final Color navSelected;

  /// Pressed list row.
  final Color rowPressed;

  /// Behind sheets and dialogs: rgba(16,24,40,.42) and rgba(0,0,0,.6).
  final Color scrim;

  /// Destructive button fill.
  final Color destructive;

  /// The destructive button's label, white in both themes.
  final Color onDestructive;

  /// Error message box background.
  final Color errorBox;

  /// Error message box text and icon.
  final Color onErrorBox;

  /// Warning message box background.
  final Color warningBox;

  /// Warning message box text and icon.
  final Color onWarningBox;

  /// Success message box background.
  final Color successBox;

  /// Success message box text and icon.
  final Color onSuccessBox;

  /// Info message box background.
  final Color infoBox;

  /// Info message box text and icon.
  final Color onInfoBox;

  /// Every token by name, so tests can check both palettes cover them all.
  @visibleForTesting
  Map<String, Color> get tokens => {
    'ground': ground,
    'surface': surface,
    'raised': raised,
    'ink': ink,
    'onInk': onInk,
    'inkPressed': inkPressed,
    'muted': muted,
    'positive': positive,
    'negative': negative,
    'warning': warning,
    'hero': hero,
    'heroTrack': heroTrack,
    'divider': divider,
    'fillSoft': fillSoft,
    'control': control,
    'buttonDisabled': buttonDisabled,
    'onButtonDisabled': onButtonDisabled,
    'disabled': disabled,
    'chipText': chipText,
    'navSelected': navSelected,
    'rowPressed': rowPressed,
    'scrim': scrim,
    'destructive': destructive,
    'onDestructive': onDestructive,
    'errorBox': errorBox,
    'onErrorBox': onErrorBox,
    'warningBox': warningBox,
    'onWarningBox': onWarningBox,
    'successBox': successBox,
    'onSuccessBox': onSuccessBox,
    'infoBox': infoBox,
    'onInfoBox': onInfoBox,
  };

  @override
  AppColors copyWith({
    Color? ground,
    Color? surface,
    Color? raised,
    Color? ink,
    Color? onInk,
    Color? inkPressed,
    Color? muted,
    Color? positive,
    Color? negative,
    Color? warning,
    Color? hero,
    Color? heroTrack,
    Color? divider,
    Color? fillSoft,
    Color? control,
    Color? buttonDisabled,
    Color? onButtonDisabled,
    Color? disabled,
    Color? chipText,
    Color? navSelected,
    Color? rowPressed,
    Color? scrim,
    Color? destructive,
    Color? onDestructive,
    Color? errorBox,
    Color? onErrorBox,
    Color? warningBox,
    Color? onWarningBox,
    Color? successBox,
    Color? onSuccessBox,
    Color? infoBox,
    Color? onInfoBox,
  }) {
    return AppColors(
      ground: ground ?? this.ground,
      surface: surface ?? this.surface,
      raised: raised ?? this.raised,
      ink: ink ?? this.ink,
      onInk: onInk ?? this.onInk,
      inkPressed: inkPressed ?? this.inkPressed,
      muted: muted ?? this.muted,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      warning: warning ?? this.warning,
      hero: hero ?? this.hero,
      heroTrack: heroTrack ?? this.heroTrack,
      divider: divider ?? this.divider,
      fillSoft: fillSoft ?? this.fillSoft,
      control: control ?? this.control,
      buttonDisabled: buttonDisabled ?? this.buttonDisabled,
      onButtonDisabled: onButtonDisabled ?? this.onButtonDisabled,
      disabled: disabled ?? this.disabled,
      chipText: chipText ?? this.chipText,
      navSelected: navSelected ?? this.navSelected,
      rowPressed: rowPressed ?? this.rowPressed,
      scrim: scrim ?? this.scrim,
      destructive: destructive ?? this.destructive,
      onDestructive: onDestructive ?? this.onDestructive,
      errorBox: errorBox ?? this.errorBox,
      onErrorBox: onErrorBox ?? this.onErrorBox,
      warningBox: warningBox ?? this.warningBox,
      onWarningBox: onWarningBox ?? this.onWarningBox,
      successBox: successBox ?? this.successBox,
      onSuccessBox: onSuccessBox ?? this.onSuccessBox,
      infoBox: infoBox ?? this.infoBox,
      onInfoBox: onInfoBox ?? this.onInfoBox,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      ground: Color.lerp(ground, other.ground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      onInk: Color.lerp(onInk, other.onInk, t)!,
      inkPressed: Color.lerp(inkPressed, other.inkPressed, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      hero: Color.lerp(hero, other.hero, t)!,
      heroTrack: Color.lerp(heroTrack, other.heroTrack, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      fillSoft: Color.lerp(fillSoft, other.fillSoft, t)!,
      control: Color.lerp(control, other.control, t)!,
      buttonDisabled: Color.lerp(buttonDisabled, other.buttonDisabled, t)!,
      onButtonDisabled: Color.lerp(
        onButtonDisabled,
        other.onButtonDisabled,
        t,
      )!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      chipText: Color.lerp(chipText, other.chipText, t)!,
      navSelected: Color.lerp(navSelected, other.navSelected, t)!,
      rowPressed: Color.lerp(rowPressed, other.rowPressed, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      onDestructive: Color.lerp(onDestructive, other.onDestructive, t)!,
      errorBox: Color.lerp(errorBox, other.errorBox, t)!,
      onErrorBox: Color.lerp(onErrorBox, other.onErrorBox, t)!,
      warningBox: Color.lerp(warningBox, other.warningBox, t)!,
      onWarningBox: Color.lerp(onWarningBox, other.onWarningBox, t)!,
      successBox: Color.lerp(successBox, other.successBox, t)!,
      onSuccessBox: Color.lerp(onSuccessBox, other.onSuccessBox, t)!,
      infoBox: Color.lerp(infoBox, other.infoBox, t)!,
      onInfoBox: Color.lerp(onInfoBox, other.onInfoBox, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
