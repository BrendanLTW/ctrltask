import 'package:ctrltask/features/notifications/domain/notification_scheduler.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asks the phone for notification permission (S05, S39), remembers that
/// it asked, and refreshes S39's state. True when granted.
Future<bool> askForNotifications(WidgetRef ref) async {
  final granted = await ref
      .read(notificationSchedulerProvider)
      .requestPermission();
  await ref
      .read(preferencesRepositoryProvider)
      .update((p) => p.copyWith(notificationsAsked: true));
  ref.invalidate(notificationsPermittedProvider);
  return granted;
}
