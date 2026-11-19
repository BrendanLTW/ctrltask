import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_motion.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Opens a bottom sheet (DESIGN §6): `surface`, top corners 32, a handle,
/// a header with [title] and [trailing] (✕ close by default), then
/// [builder]'s content. It slides up in 280 ms (instant with reduced
/// motion) and leaves at least 100 px of the screen above it.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  Widget? trailing,
}) {
  final colors = context.colors;
  final motion = AppMotion.of(context);
  return showModalBottomSheet<T>(
    context: context,
    // Above the tab shell, so the floating bottom bar can't cover it.
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: colors.surface,
    elevation: 0,
    barrierColor: colors.scrim,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height - 100,
    ),
    sheetAnimationStyle: motion.reduced
        ? AnimationStyle.noAnimation
        : AnimationStyle(duration: motion.sheet, curve: AppMotion.easeOut),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r32)),
    ),
    builder: (context) =>
        AppSheet(title: title, trailing: trailing, child: builder(context)),
  );
}

/// The sheet's frame; use [showAppSheet] to open one.
class AppSheet extends StatelessWidget {
  const new({
    required this.title,
    required this.child,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      // Keeps fields above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 5,
              decoration: ShapeDecoration(
                color: colors.control,
                shape: const StadiumBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: context.text.header.copyWith(color: colors.ink),
                    ),
                  ),
                ),
                trailing ??
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: context.l10n.close,
                      style: IconButton.styleFrom(
                        fixedSize: const Size(44, 44),
                        foregroundColor: colors.ink,
                      ),
                      icon: const AppIconView(AppIcon.close, size: 24),
                    ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
