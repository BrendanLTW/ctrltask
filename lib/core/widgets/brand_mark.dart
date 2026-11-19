import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/theme/brand_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The keycap with the orange check (DESIGN §2). Decorative: the wordmark
/// or screen title names the app.
class BrandMark extends StatelessWidget {
  const new({this.size = 116, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/brand/ctrltask_mark.svg',
    width: size,
    height: size,
    excludeFromSemantics: true,
  );
}

/// "ctrlTask": "ctrl" in 400 grey, "Task" in 700 (DESIGN §2). [onDark]
/// uses the dark-background colours, as on the splash.
class Wordmark extends StatelessWidget {
  const new({this.onDark = false, super.key});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final style = context.text.wordmark;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'ctrl',
            style: style.copyWith(
              color: onDark ? BrandColors.ctrlOnDark : BrandColors.ctrlOnLight,
            ),
          ),
          TextSpan(
            text: 'Task',
            style: style.copyWith(
              fontWeight: FontWeight.w700,
              color: onDark ? BrandColors.taskOnDark : BrandColors.taskOnLight,
            ),
          ),
        ],
      ),
      semanticsLabel: 'ctrlTask',
    );
  }
}
