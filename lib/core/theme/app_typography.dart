import 'package:flutter/widgets.dart';

const _family = 'Poppins';
const _tabular = [FontFeature.tabularFigures()];

/// Text styles from DESIGN §4. Read them with `context.text`.
///
/// Styles carry no colour, so text takes `ink` from the theme unless a widget
/// sets one.
@immutable
class AppTypography {
  const new();

  /// Focus timer: 18:42.
  TextStyle get timer => const TextStyle(
    fontFamily: _family,
    fontSize: 60,
    fontWeight: FontWeight.w700,
    letterSpacing: -2,
    height: 1,
    fontFeatures: _tabular,
  );

  /// Hero value: "2 of 6 done", 78%.
  TextStyle get heroValue => const TextStyle(
    fontFamily: _family,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.2,
    fontFeatures: _tabular,
  );

  /// The wordmark: "ctrl" at this weight, "Task" at w700, −2% letter-spacing
  /// (DESIGN §2).
  TextStyle get wordmark => const TextStyle(
    fontFamily: _family,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.72,
    height: 1.1,
  );

  /// Onboarding titles.
  TextStyle get onbTitle => const TextStyle(
    fontFamily: _family,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.2,
    fontFeatures: _tabular,
  );

  /// Tab titles: Tasks, Projects, Focus.
  TextStyle get pageTitle => const TextStyle(
    fontFamily: _family,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
    fontFeatures: _tabular,
  );

  /// Task detail title.
  TextStyle get detailTitle => const TextStyle(
    fontFamily: _family,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
    fontFeatures: _tabular,
  );

  /// The hero value's unit, shown smaller: "2 of 6 done".
  TextStyle get heroUnit => const TextStyle(
    fontFamily: _family,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.2,
    fontFeatures: _tabular,
  );

  /// Empty, done and error state titles.
  TextStyle get stateTitle => const TextStyle(
    fontFamily: _family,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
    fontFeatures: _tabular,
  );

  /// Sheet, dialog and sub-screen titles; Home greeting.
  TextStyle get header => const TextStyle(
    fontFamily: _family,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    fontFeatures: _tabular,
  );

  /// Project card names.
  TextStyle get cardTitle => const TextStyle(
    fontFamily: _family,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.3,
    fontFeatures: _tabular,
  );

  /// Task titles in cards and rows.
  TextStyle get rowTitle => const TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
    fontFeatures: _tabular,
  );

  /// Supporting copy, settings rows, inputs. Use w500 where the design does.
  TextStyle get body => const TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    fontFeatures: _tabular,
  );

  /// Primary button label.
  TextStyle get button => const TextStyle(
    fontFamily: _family,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1,
    fontFeatures: _tabular,
  );

  /// Chips, segments, pills, section links.
  TextStyle get chip => const TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1,
    fontFeatures: _tabular,
  );

  /// The hero's sub line: "4 left · next: Review wireframes".
  TextStyle get subline => const TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    fontFeatures: _tabular,
  );

  /// Meta lines: 10:00 AM · Website redesign.
  TextStyle get caption => const TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    fontFeatures: _tabular,
  );

  /// Message box text.
  TextStyle get message => const TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.45,
    fontFeatures: _tabular,
  );

  /// Section labels; the ARB copy holds the uppercase text.
  TextStyle get label => const TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.7,
    height: 1.3,
    fontFeatures: _tabular,
  );

  /// Stat tile and sheet labels (11–12); uppercase in the ARB copy.
  TextStyle get labelSm => const TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.7,
    height: 1.3,
    fontFeatures: _tabular,
  );

  /// Priority tags, tag chips, counts.
  TextStyle get tag => const TextStyle(
    fontFamily: _family,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1,
    fontFeatures: _tabular,
  );

  /// Stat tile values: 12 days, 1h 15m.
  TextStyle get statValue => const TextStyle(
    fontFamily: _family,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.25,
    fontFeatures: _tabular,
  );
}

extension AppTypographyContext on BuildContext {
  AppTypography get text => const AppTypography();
}
