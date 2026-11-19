import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_motion.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// An action revealed by swiping a row left.
typedef SwipeAction = ({
  String label,
  AppIcon icon,
  ProjectColorKey color,
  VoidCallback onTap,
});

/// A row that completes when swiped right and reveals [actions] when
/// swiped left (S19). Screen readers get every action as a custom action.
class SwipeActions extends StatefulWidget {
  const new({
    required this.child,
    required this.completeLabel,
    required this.onComplete,
    required this.actions,
    super.key,
  });

  final Widget child;
  final String completeLabel;

  /// Null for a row that can't be completed (a done task).
  final VoidCallback? onComplete;
  final List<SwipeAction> actions;

  /// Each revealed action's width.
  static const actionWidth = 76.0;

  @override
  State<SwipeActions> createState() => _SwipeActionsState();
}

class _SwipeActionsState extends State<SwipeActions>
    with SingleTickerProviderStateMixin {
  late final _offset = AnimationController.unbounded(vsync: this)
    ..addListener(() => setState(() {}));

  double get _reveal => SwipeActions.actionWidth * widget.actions.length;

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  Future<void> _settle(double to) => _offset.animateTo(
    to,
    duration: AppMotion.of(context).toggle,
    curve: AppMotion.easeOut,
  );

  void _onDrag(DragUpdateDetails details, double width) {
    final max = widget.onComplete == null ? 0.0 : width;
    _offset.value = (_offset.value + details.primaryDelta!).clamp(
      -_reveal,
      max,
    );
  }

  void _onDragEnd(DragEndDetails details, double width) {
    final x = _offset.value;
    final fling = details.primaryVelocity ?? 0;
    if (x > 0) {
      if (x > width * 0.35 || fling > 800) widget.onComplete?.call();
      _settle(0).ignore();
    } else {
      _settle(x < -_reveal / 2 || fling < -800 ? -_reveal : 0).ignore();
    }
  }

  void _run(VoidCallback action) {
    _settle(0).ignore();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = context.projectColors;
    final x = _offset.value;
    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: widget.completeLabel): ?widget.onComplete,
        for (final action in widget.actions)
          CustomSemanticsAction(label: action.label): action.onTap,
      },
      child: LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          onHorizontalDragUpdate: (d) => _onDrag(d, constraints.maxWidth),
          onHorizontalDragEnd: (d) => _onDragEnd(d, constraints.maxWidth),
          child: Stack(
            children: [
              if (x > 0)
                Positioned.fill(
                  child: ColoredBox(
                    color: colors.successBox,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 24),
                        child: AppIconView(
                          AppIcon.check,
                          size: 24,
                          color: colors.onSuccessBox,
                        ),
                      ),
                    ),
                  ),
                )
              else if (x < 0)
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for (final action in widget.actions)
                        ExcludeSemantics(
                          child: SizedBox(
                            width: SwipeActions.actionWidth,
                            child: Material(
                              color: palette.of(action.color).tile,
                              child: InkWell(
                                onTap: () => _run(action.onTap),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AppIconView(
                                      action.icon,
                                      size: 22,
                                      color: palette.of(action.color).icon,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      action.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.text.tag.copyWith(
                                        color: palette.of(action.color).icon,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              Transform.translate(
                offset: Offset(x, 0),
                child: ColoredBox(
                  color: colors.surface,
                  // While open, a tap on the row closes it.
                  child: AbsorbPointer(absorbing: x < 0, child: widget.child),
                ),
              ),
              if (x < 0)
                Positioned.fill(
                  right: -x,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _settle(0).ignore(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
