import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/theme/brand_colors.dart';
import 'package:ctrltask/core/widgets/brand_mark.dart';
import 'package:ctrltask/features/onboarding/presentation/onboarding_controller.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S01 Splash, shown on every launch while settings load. Moves on once
/// they have loaded and the loading bar has run, or straight away on tap.
class SplashScreen extends ConsumerStatefulWidget {
  const new({super.key});

  static const minimumDuration = Duration(milliseconds: 1500);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final _progress = AnimationController(
    vsync: this,
    duration: SplashScreen.minimumDuration,
  );
  var _ready = false;
  var _left = false;

  @override
  void initState() {
    super.initState();
    _progress
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _continue();
      })
      ..forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  /// Leaves once settings have loaded; called when the bar finishes, on
  /// tap, and when the settings arrive after either.
  void _continue() {
    _ready = true;
    final onboarded = ref.read(onboardingCompleteProvider);
    if (onboarded == null || _left || !mounted) return;
    _left = true;
    context.go(onboarded ? Routes.home : Routes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(onboardingCompleteProvider, (_, next) {
      if (_ready && next != null) _continue();
    });
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    // Navy in light; the ground in dark, as the S01 dark design shows.
    final background = Theme.of(context).brightness == Brightness.light
        ? colors.hero
        : colors.ground;
    return Scaffold(
      backgroundColor: background,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _continue,
        child: Stack(
          children: [
            // Two faint rings behind the mark.
            for (final size in [300.0, 420.0])
              Align(
                alignment: const Alignment(0, -0.15),
                child: ExcludeSemantics(
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.onHero.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                ),
              ),
            Align(
              alignment: const Alignment(0, -0.08),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandMark(),
                  const SizedBox(height: 30),
                  const Wordmark(onDark: true),
                  const SizedBox(height: 10),
                  Text(
                    l10n.splashTagline,
                    style: text.body.copyWith(color: colors.heroUnit),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 110,
              child: Center(
                child: ExcludeSemantics(
                  child: SizedBox(
                    width: 120,
                    height: 4,
                    child: AnimatedBuilder(
                      animation: _progress,
                      builder: (context, _) => LinearProgressIndicator(
                        value: _progress.value,
                        color: BrandColors.orange,
                        backgroundColor: colors.heroTrack,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 48,
              child: Text.rich(
                TextSpan(
                  text: l10n.makerPrefix,
                  style: text.chip.copyWith(
                    color: colors.heroUnit,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(
                      text: l10n.makerName,
                      style: text.chip.copyWith(color: colors.heroLabel),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
