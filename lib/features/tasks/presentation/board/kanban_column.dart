import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// One S20 column (DESIGN §7): 276 wide, a status dot, the name and a count
/// pill, the cards, and Add task. Cards dropped on it from another column
/// call [onDrop].
class KanbanColumn extends StatelessWidget {
  const new({
    required this.column,
    required this.cards,
    required this.onDrop,
    this.onAdd,
    super.key,
  });

  static const width = 276.0;

  final BoardColumn column;
  final List<Widget> cards;
  final void Function(Task) onDrop;

  /// Add task; none on Done, where a new task can't start.
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final name = l10n.columnName(column.name);
    final dot = context.projectColors.of(switch (column) {
      BoardColumn.todo => ProjectColorKey.grey,
      BoardColumn.doing => ProjectColorKey.blue,
      BoardColumn.done => ProjectColorKey.green,
    });
    return DragTarget<Task>(
      onWillAcceptWithDetails: (d) => d.data.boardColumn != column,
      onAcceptWithDetails: (d) => onDrop(d.data),
      builder: (context, hovering, _) => Container(
        width: width,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          // Where the card will land.
          color: hovering.isEmpty ? null : colors.raised,
          borderRadius: BorderRadius.circular(AppRadius.r24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              label: l10n.columnSemantics(name, cards.length),
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dot.solid,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        name,
                        style: text.cardTitle.copyWith(
                          color: colors.ink,
                          fontSize: text.button.fontSize,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      constraints: const BoxConstraints(minWidth: 24),
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.raised,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '${cards.length}',
                        style: text.tag.copyWith(color: colors.chipText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (final card in cards) ...[card, const SizedBox(height: 10)],
            if (onAdd case final onAdd?) _AddTask(onTap: onAdd),
          ],
        ),
      ),
    );
  }
}

/// "+ Add task": 48 high, radius 18, a dashed 1.5 px `control` outline.
class _AddTask extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.r18),
        child: CustomPaint(
          painter: _DashedOutline(color: colors.control),
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIconView(AppIcon.add, size: 18, color: colors.muted),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    context.l10n.addTask,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.rowTitle.copyWith(color: colors.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedOutline extends CustomPainter {
  new({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 1.5;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(stroke / 2),
          const Radius.circular(AppRadius.r18),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    for (final metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 10) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedOutline old) => old.color != color;
}
