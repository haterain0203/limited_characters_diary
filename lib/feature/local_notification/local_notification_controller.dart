import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/local_notification/local_notification_repository.dart';

import 'local_notification_shared_preferences_repository.dart';

final localNotificationControllerProvider = Provider(
  (ref) => LocalNotificationController(ref: ref),
);

final localNotificationRepoProvider = Provider<LocalNotificationRepository>(
  (ref) {
    //main.dartで上書きされる
    throw UnimplementedError();
  },
);

final localNotificationSharedRepoProvider = Provider(
  (ref) => LocalNotificationSharedPreferencesRepository(),
);

// SharedPreferencesにアクセスし、記録された通知時間の文字列を取得
// TimeOfDayに直して返す
final localNotificationTimeFutureProvider =
    FutureProvider.autoDispose((ref) async {
  final repo = ref.read(localNotificationSharedRepoProvider);
  final notificationTimeStr = await repo.fetchNotificationTimeStr();
  if (notificationTimeStr == null) {
    return null;
  }
  final notificationTimeDateTime = DateTime.parse(notificationTimeStr);
  final notificationTime = TimeOfDay.fromDateTime(notificationTimeDateTime);
  return notificationTime;
});

class LocalNotificationController {
  LocalNotificationController({required this.ref});

  final ProviderRef<dynamic> ref;

  Future<void> scheduledNotification(TimeOfDay setTime) async {
    final repo = ref.watch(localNotificationRepoProvider);
    await repo.scheduledNotification(notificationTime: setTime);
  }

  Future<void> saveNotificationTime(TimeOfDay notificationTime) async {
    final repo = ref.read(localNotificationSharedRepoProvider);
    await repo.saveNotificationTime(notificationTime);
  }
}
