import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'haptics.g.dart';

/// Haptic feedback, behind a provider so tests can swap in a fake.
class Haptics {
  const new();

  /// The tick when a task is completed (PRD §6.1).
  Future<void> light() => HapticFeedback.lightImpact();
}

@Riverpod(keepAlive: true)
Haptics haptics(Ref ref) => const Haptics();
