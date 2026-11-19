import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/core/widgets/task_checkbox.dart';
import 'package:ctrltask/features/tasks/domain/subtask.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S11's subtasks: tick or remove each, and add more inline (up to 50).
class SubtaskSection extends StatefulWidget {
  const new({
    required this.subtasks,
    required this.onAdd,
    required this.onToggle,
    required this.onRemove,
    super.key,
  });

  final List<Subtask> subtasks;
  final ValueChanged<String> onAdd;
  final void Function(int index, {required bool done}) onToggle;
  final ValueChanged<int> onRemove;

  @override
  State<SubtaskSection> createState() => _SubtaskSectionState();
}

class _SubtaskSectionState extends State<SubtaskSection> {
  final _new = TextEditingController();
  final _focus = FocusNode();
  var _adding = false;

  @override
  void dispose() {
    _new.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit(String value) {
    if (value.trim().isNotEmpty) widget.onAdd(value.trim());
    _new.clear();
    // Stays open for the next one.
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final subtasks = widget.subtasks;
    final done = subtasks.where((s) => s.done).length;
    final style = text.rowTitle.copyWith(
      color: colors.ink,
      fontWeight: FontWeight.w500,
    );
    final canAdd = subtasks.length < maxSubtasksPerTask;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l10n.subtasksHeader(done, subtasks.length)),
        ListGroup(
          children: [
            for (final (i, s) in subtasks.indexed)
              Padding(
                padding: const EdgeInsets.fromLTRB(7, 4, 4, 4),
                child: Row(
                  children: [
                    TaskCheckbox(
                      title: s.title,
                      priority: TaskPriority.low,
                      done: s.done,
                      size: 22,
                      onChanged: (v) => widget.onToggle(i, done: v),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.title,
                        style: s.done
                            ? style.copyWith(
                                color: colors.muted,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: colors.muted,
                              )
                            : style,
                      ),
                    ),
                    IconButton(
                      onPressed: () => widget.onRemove(i),
                      tooltip: l10n.removeSubtask,
                      color: colors.muted,
                      icon: const AppIconView(AppIcon.close, size: 18),
                    ),
                  ],
                ),
              ),
            if (canAdd && _adding)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: TextField(
                  controller: _new,
                  focusNode: _focus,
                  autofocus: true,
                  maxLength: maxTaskTitleLength,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onSubmitted: _submit,
                  style: style,
                  cursorColor: colors.ink,
                  decoration: InputDecoration.collapsed(
                    hintText: l10n.subtaskHint,
                    hintStyle: style.copyWith(color: colors.disabled),
                  ).copyWith(counterText: ''),
                ),
              )
            else if (canAdd)
              ListGroupRow(
                title: l10n.addSubtask,
                titleColor: colors.muted,
                leading: AppIconView(
                  AppIcon.add,
                  size: 22,
                  color: colors.muted,
                ),
                onTap: () => setState(() => _adding = true),
                chevron: false,
              ),
          ],
        ),
      ],
    );
  }
}
