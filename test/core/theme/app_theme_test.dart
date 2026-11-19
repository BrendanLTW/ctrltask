import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_motion.dart';
import 'package:ctrltask/core/theme/app_shadows.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/theme/theme_mode_controller.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_preferences_repository.dart';

class _Sample extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Body copy', style: context.text.body),
          const Text('Default'),
          Text('18:42', style: context.text.timer),
        ],
      ),
    );
  }
}

void main() {
  for (final (name, theme, colors, projects, shadows) in [
    (
      'light',
      buildLightTheme(),
      AppColors.light,
      ProjectColors.light,
      AppShadows.light,
    ),
    (
      'dark',
      buildDarkTheme(),
      AppColors.dark,
      ProjectColors.dark,
      AppShadows.dark,
    ),
  ]) {
    group('$name theme', () {
      Future<BuildContext> pumpSample(WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(theme: theme, home: const _Sample()),
        );
        return tester.element(find.byType(_Sample));
      }

      TextStyle styleOf(WidgetTester tester, String text) =>
          tester.renderObject<RenderParagraph>(find.text(text)).text.style!;

      testWidgets('screen background is ground', (tester) async {
        await pumpSample(tester);
        final scaffold = tester.widget<Material>(
          find
              .descendant(
                of: find.byType(Scaffold),
                matching: find.byType(Material),
              )
              .first,
        );
        expect(scaffold.color, colors.ground);
      });

      testWidgets('text is Poppins in ink with tabular figures', (
        tester,
      ) async {
        await pumpSample(tester);
        for (final text in ['Body copy', 'Default', '18:42']) {
          final style = styleOf(tester, text);
          expect(style.fontFamily, 'Poppins', reason: text);
          expect(style.color, colors.ink, reason: text);
        }
        expect(
          styleOf(tester, '18:42').fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      });

      testWidgets('extensions resolve from context', (tester) async {
        final context = await pumpSample(tester);
        expect(context.colors, same(colors));
        expect(context.projectColors, same(projects));
        expect(context.shadows, same(shadows));
      });
    });
  }

  testWidgets('the app follows the stored theme', (tester) async {
    final prefs = FakePreferencesRepository(
      const Preferences(onboardingComplete: true),
    );
    final container = ProviderContainer(
      overrides: [preferencesRepositoryProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    expect(container.read(appThemeModeProvider), ThemeMode.system);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    await tester.pumpAndSettle();
    Brightness brightness() =>
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness;

    for (final (theme, expected) in [
      (AppTheme.dark, Brightness.dark),
      (AppTheme.light, Brightness.light),
    ]) {
      await prefs.update((p) => p.copyWith(theme: theme));
      await tester.pumpAndSettle();
      expect(brightness(), expected);
    }
  });

  testWidgets('reduced motion turns animations off', (tester) async {
    late AppMotion normal;
    late AppMotion reduced;
    Widget probe(void Function(AppMotion) out, {required bool disable}) =>
        MediaQuery(
          data: MediaQueryData(disableAnimations: disable),
          child: Builder(
            builder: (context) {
              out(AppMotion.of(context));
              return const SizedBox();
            },
          ),
        );

    await tester.pumpWidget(probe((m) => normal = m, disable: false));
    await tester.pumpWidget(probe((m) => reduced = m, disable: true));

    expect(normal.complete, const Duration(milliseconds: 350));
    expect(reduced.complete, Duration.zero);
    expect(reduced.sheet, Duration.zero);
    expect(reduced.toggle, Duration.zero);
    expect(AppMotion.toastHold, const Duration(milliseconds: 3500));
  });
}
