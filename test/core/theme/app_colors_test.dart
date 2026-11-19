import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors', () {
    test('light and dark define all 32 tokens', () {
      expect(AppColors.light.tokens, hasLength(32));
      expect(AppColors.dark.tokens.keys, AppColors.light.tokens.keys);
    });

    test('tokens that differ from ctrlSpend match DESIGN §3.1–3.3', () {
      expect(AppColors.dark.control, const Color(0xFF475467));
      expect(AppColors.dark.disabled, const Color(0xFF667085));
      expect(AppColors.light.successBox, const Color(0xFFC9F3D5));
      expect(AppColors.dark.infoBox, const Color(0xFF232C3A));
      expect(
        (AppColors.light.rowPressed, AppColors.dark.rowPressed),
        (const Color(0xFFFAFBFC), const Color(0xFF1B2331)),
      );
    });

    test('translucent tokens match their rgba values', () {
      // Compare as 8-bit ARGB: the tokens store alpha in 8 bits.
      void expectRgba(Color token, int r, int g, int b, double opacity) =>
          expect(token.toARGB32(), Color.fromRGBO(r, g, b, opacity).toARGB32());

      expectRgba(AppColors.light.scrim, 16, 24, 40, .42);
      expectRgba(AppColors.dark.scrim, 0, 0, 0, .6);
      // The dark boxes are their colour at 16%.
      expectRgba(AppColors.dark.errorBox, 240, 68, 56, .16);
      expectRgba(AppColors.dark.warningBox, 247, 144, 9, .16);
      expectRgba(AppColors.dark.successBox, 23, 178, 106, .16);
    });

    test('lerp returns each end at 0 and 1', () {
      const light = AppColors.light;
      const dark = AppColors.dark;
      expect(light.lerp(dark, 0).tokens, light.tokens);
      expect(light.lerp(dark, 1).tokens, dark.tokens);
    });

    test('copyWith changes only the given token', () {
      const red = Color(0xFFFF0000);
      final copy = AppColors.light.copyWith(muted: red);
      expect(copy.tokens, {...AppColors.light.tokens, 'muted': red});
    });
  });

  group('ProjectColors', () {
    test('light and dark cover every colour key', () {
      expect(ProjectColors.light.colors.keys, ProjectColorKey.values);
      expect(ProjectColors.dark.colors.keys, ProjectColorKey.values);
    });

    test('values match DESIGN §3.4', () {
      expect(ProjectColors.light.of(ProjectColorKey.purple), (
        tile: const Color(0xFFE4DBF7),
        icon: const Color(0xFF6D3FD1),
        solid: const Color(0xFF7C4DDB),
      ));
      expect(
        ProjectColors.dark.of(ProjectColorKey.grey).solid,
        const Color(0xFF475467),
      );
    });

    test('lerp returns each end at 0 and 1', () {
      const light = ProjectColors.light;
      const dark = ProjectColors.dark;
      expect(light.lerp(dark, 0).colors, light.colors);
      expect(light.lerp(dark, 1).colors, dark.colors);
    });
  });

  testWidgets('context reads both theme extensions', (tester) async {
    late AppColors colors;
    late ProjectColors projectColors;
    await tester.pumpWidget(
      Theme(
        data: ThemeData(extensions: const [AppColors.dark, ProjectColors.dark]),
        child: Builder(
          builder: (context) {
            colors = context.colors;
            projectColors = context.projectColors;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(colors, same(AppColors.dark));
    expect(projectColors, same(ProjectColors.dark));
  });
}
