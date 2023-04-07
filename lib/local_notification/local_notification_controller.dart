import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/local_notification/local_notification_repository.dart';
import 'package:limited_characters_diary/local_notification/local_notification_shared_preferences_repository.dart';

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

final localNotificationSharedRepoProvider = Provider(
  (ref) => LocalNotificationSharedPreferencesRepository(),
);

// SharedPreferencesにアクセスし、記録された通知時間を取得する
final localNotificationTimeFutureProvider = FutureProvider((ref) async {
  final repo = ref.read(localNotificationSharedRepoProvider);
  await repo.fetchNotificationTime();
});

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
