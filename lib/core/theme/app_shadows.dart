import 'package:flutter/material.dart';

/// Shadows for floating elements (DESIGN §5). Cards are flat.
/// Read them with `context.shadows`.
@immutable
class AppShadows extends ThemeExtension<AppShadows> {
  const new({
    required this.bottomBar,
    required this.quickAdd,
    required this.toast,
    required this.dialog,
    required this.toggleKnob,
    required this.kanbanDrag,
  });

  static const light = AppShadows(
    bottomBar: [
      BoxShadow(
        offset: Offset(0, 8),
        blurRadius: 28,
        color: Color.fromRGBO(16, 24, 40, 0.08),
      ),
    ],
    quickAdd: [
      BoxShadow(
        offset: Offset(0, 10),
        blurRadius: 24,
        color: Color.fromRGBO(16, 24, 40, 0.28),
      ),
    ],
    toast: [_toast],
    dialog: [_dialog],
    toggleKnob: [_toggleKnob],
    kanbanDrag: [_kanbanDrag],
  );

  static const dark = AppShadows(
    bottomBar: [
      BoxShadow(
        offset: Offset(0, 8),
        blurRadius: 28,
        color: Color.fromRGBO(0, 0, 0, 0.5),
      ),
    ],
    quickAdd: [
      BoxShadow(
        offset: Offset(0, 10),
        blurRadius: 24,
        color: Color.fromRGBO(0, 0, 0, 0.5),
      ),
    ],
    toast: [_toast],
    dialog: [_dialog],
    toggleKnob: [_toggleKnob],
    kanbanDrag: [_kanbanDrag],
  );

  static const _toast = BoxShadow(
    offset: Offset(0, 10),
    blurRadius: 24,
    color: Color.fromRGBO(16, 24, 40, 0.25),
  );
  static const _dialog = BoxShadow(
    offset: Offset(0, 24),
    blurRadius: 48,
    color: Color.fromRGBO(16, 24, 40, 0.24),
  );

  /// A dragged Kanban card (DESIGN §6); the same in both themes.
  static const _kanbanDrag = BoxShadow(
    offset: Offset(0, 18),
    blurRadius: 36,
    color: Color.fromRGBO(16, 24, 40, 0.18),
  );

  /// "A small shadow" on the toggle thumb (DESIGN §7); the same in both themes.
  static const _toggleKnob = BoxShadow(
    offset: Offset(0, 1),
    blurRadius: 3,
    color: Color.fromRGBO(16, 24, 40, 0.2),
  );

  final List<BoxShadow> bottomBar;
  final List<BoxShadow> quickAdd;
  final List<BoxShadow> toast;
  final List<BoxShadow> dialog;
  final List<BoxShadow> toggleKnob;

  /// A Kanban card being dragged (S20).
  final List<BoxShadow> kanbanDrag;

  @override
  AppShadows copyWith({
    List<BoxShadow>? bottomBar,
    List<BoxShadow>? quickAdd,
    List<BoxShadow>? toast,
    List<BoxShadow>? dialog,
    List<BoxShadow>? toggleKnob,
    List<BoxShadow>? kanbanDrag,
  }) {
    return AppShadows(
      bottomBar: bottomBar ?? this.bottomBar,
      quickAdd: quickAdd ?? this.quickAdd,
      toast: toast ?? this.toast,
      dialog: dialog ?? this.dialog,
      toggleKnob: toggleKnob ?? this.toggleKnob,
      kanbanDrag: kanbanDrag ?? this.kanbanDrag,
    );
  }

  @override
  AppShadows lerp(AppShadows? other, double t) {
    if (other == null) return this;
    return AppShadows(
      bottomBar: BoxShadow.lerpList(bottomBar, other.bottomBar, t)!,
      quickAdd: BoxShadow.lerpList(quickAdd, other.quickAdd, t)!,
      toast: BoxShadow.lerpList(toast, other.toast, t)!,
      dialog: BoxShadow.lerpList(dialog, other.dialog, t)!,
      toggleKnob: BoxShadow.lerpList(toggleKnob, other.toggleKnob, t)!,
      kanbanDrag: BoxShadow.lerpList(kanbanDrag, other.kanbanDrag, t)!,
    );
  }
}

extension AppShadowsContext on BuildContext {
  AppShadows get shadows => Theme.of(this).extension<AppShadows>()!;
}
