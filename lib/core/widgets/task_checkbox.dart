import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_motion.dart';
import 'package:ctrltask/core/theme/priority_colors.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The round task checkbox (DESIGN §7): a ring in the priority colour, or an
/// `ink` fill with a check when [done]. Ticking springs it in (DESIGN §9).
/// The tap area is always 44 × 44.
class TaskCheckbox extends StatefulWidget {
  const new({
    required this.title,
    required this.priority,
    required this.done,
    required this.onChanged,
    this.size = 26,
    super.key,
  });

  /// The task's title, for the screen-reader label.
  final String title;
  final TaskPriority priority;
  final bool done;
  final ValueChanged<bool> onChanged;

  /// 26 for tasks, 22 for subtasks.
  final double size;

  static const double target = 44;

  @override
  State<TaskCheckbox> createState() => _TaskCheckboxState();
}

class _TaskCheckboxState extends State<TaskCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tick = AnimationController(
    vsync: this,
    value: 1,
  );
  bool _pressed = false;

  static final Animatable<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.18), weight: 60),
    TweenSequenceItem(tween: Tween(begin: 1.18, end: 1), weight: 40),
  ]).chain(CurveTween(curve: AppMotion.easeOut));

  @override
  void didUpdateWidget(TaskCheckbox old) {
    super.didUpdateWidget(old);
    if (widget.done && !old.done) {
      _tick
        ..duration = AppMotion.of(context).complete
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _tick.dispose();
    super.dispose();
  }

  void _setPressed(bool pressed) => setState(() => _pressed = pressed);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final done = widget.done;
    final size = widget.size;
    // Its own node, so it stays tappable inside a tappable card.
    return Semantics(
      container: true,
      button: true,
      checked: done,
      label: done
          ? l10n.checkboxReopen(widget.title)
          : l10n.checkboxComplete(widget.title),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: () => widget.onChanged(!done),
        child: SizedBox.square(
          dimension: TaskCheckbox.target,
          child: Center(
            child: AnimatedBuilder(
              animation: _tick,
              builder: (context, _) => Transform.scale(
                scale: done ? _scale.evaluate(_tick) : 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? colors.ink
                        : _pressed
                        ? colors.fillSoft
                        : null,
                    border: done
                        ? null
                        : Border.all(
                            color: context.priorityRing(widget.priority),
                            width: 2,
                          ),
                  ),
                  child: SizedBox.square(
                    dimension: size,
                    child: done
                        ? Opacity(
                            opacity: _tick.value,
                            child: AppIconView(
                              AppIcon.check,
                              size: size * 15 / 26,
                              color: colors.onInk,
                              stroke: 3,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
