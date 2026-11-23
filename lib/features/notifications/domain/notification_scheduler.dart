import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_scheduler.g.dart';

/// The phone's notification system. Everything is scheduled on the
/// device; nothing is sent to a server (PRD §6.5). Times are local.
abstract interface class NotificationScheduler {
  /// Asks the OS for permission (S05, S39). True when granted.
  Future<bool> requestPermission();

  /// Whether ctrlTask may show notifications, without asking.
  Future<bool> isPermitted();

  /// Shows once at [at].
  Future<void> scheduleOnce({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  });

  /// Cancels everything scheduled.
  Future<void> cancelAll();
}

/// Overridden in `main.dart` with the flutter_local_notifications one.
@Riverpod(keepAlive: true)
NotificationScheduler notificationScheduler(Ref ref) =>
    throw UnimplementedError('Override notificationSchedulerProvider');
