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

// 「WidgetsBinding.instance.addPostFrameCallback」は、
// ビルドするたびに呼び出されダイアログが複数重なってしまうため、
// 既にダイアログが開かれたかを判定するフラグを用意
final isOpenedSetNotificationDialogOnLaunchProvider =
    StateProvider<bool>((_) => false);

/// アラーム設定を促すダイアログを自動表示させるかどうか
///
/// 初回起動かつ、アラーム設定ダイアログが表示されていない場合には、自動表示する
final isShowSetNotificationDialogOnLaunchProvider = Provider<bool>((ref) {
  final isFirstLaunch = ref.watch(isFirstLaunchProvider);
  if (!isFirstLaunch) {
    return false;
  }

  final isOpenedSetNotificationDialog =
      ref.watch(isOpenedSetNotificationDialogOnLaunchProvider);
  if (isOpenedSetNotificationDialog) {
    return false;
  }

  return true;
});

/// 初めて通知設定したかどうかの管理
///
/// iOSの場合、初めて通知設定する際に端末の通知許可設定が表示される
/// その際アプリがinactiveになるため、パスコードロック画面が表示されてしまう
/// このinactive時にはパスコードロック画面を表示したくないため、初めて通知設定したかどうかをフラグ管理するもの
/// isShowScreenLockProviderにて使用
final isInitialSetNotificationProvider = StateProvider((ref) => false);
