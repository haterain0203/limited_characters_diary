import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/local_notification/local_notification_repository.dart';

final localNotificationControllerProvider = Provider(
  (ref) => LocalNotificationController(ref: ref),
);

final localNotificationRepoProvider = Provider((ref) {
  return LocalNotificationRepository();
});

// 通知時間の管理
// 初期値は21:00
final localNotificationSetTimeProvider =
    StateProvider<TimeOfDay>((ref) => const TimeOfDay(hour: 21, minute: 00));

class LocalNotificationController {
  LocalNotificationController({required this.ref});

  final ProviderRef<dynamic> ref;
  TimeOfDay get notificationTime => ref.watch(localNotificationSetTimeProvider);

  Future<void> scheduledNotification() async {
    final repo = ref.watch(localNotificationRepoProvider);
    await repo.scheduledNotification(notificationTime: notificationTime);
  }

  void setNotificationTime(TimeOfDay setTime) {
    ref
        .read(localNotificationSetTimeProvider.notifier)
        .update((state) => setTime);
  }
}
