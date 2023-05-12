import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/shared_preferences/shared_preferences_providers.dart';

import '../first_launch/first_launch_providers.dart';
import 'local_notification_controller.dart';
import 'local_notification_repository.dart';
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
  (ref) => LocalNotificationSharedPreferencesRepository(
    prefs: ref.watch(sharedPreferencesInstanceProvider),
  ),
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

/// 初めて通知設定したかどうかの管理
///
/// iOSの場合、初めて通知設定する際に端末の通知許可設定が表示される
/// その際アプリがinactiveになるため、パスコードロック画面が表示されてしまう
/// このinactive時にはパスコードロック画面を表示したくないため、初めて通知設定したかどうかをフラグ管理するもの
/// isShowScreenLockProviderにて使用
final isInitialSetNotificationProvider = StateProvider((ref) => false);
