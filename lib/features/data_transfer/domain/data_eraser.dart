import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_eraser.g.dart';

/// Erase all data (S44): leaves the app as a fresh install would be.
abstract interface class DataEraser {
  /// Removes every task, project, tag, focus session and setting, all at
  /// once. Settings return to their defaults, so onboarding starts again.
  Future<void> eraseAll();
}

/// Overridden in `main.dart` with the Drift implementation.
@Riverpod(keepAlive: true)
DataEraser dataEraser(Ref ref) =>
    throw UnimplementedError('Override dataEraserProvider');
