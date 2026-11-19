import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_controller.g.dart';

/// The Theme setting (S36) as a [ThemeMode]. System by default.
// shortcut: in-memory, resets on restart; task 1.7 reads the stored `theme`
// preference instead.
@Riverpod(keepAlive: true)
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() => ThemeMode.system;

  ThemeMode get mode => state;
  set mode(ThemeMode value) => state = value;
}
