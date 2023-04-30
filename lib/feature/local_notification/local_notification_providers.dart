import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

// 「WidgetsBinding.instance.addPostFrameCallback」は、
// ビルドするたびに呼び出されダイアログが複数重なってしまうため、
// 既にダイアログが開かれたかを判定するフラグを用意
final isOpenedFirstLaunchDialogProvider = StateProvider<bool>((_) => false);

/// アラーム設定を促すダイアログを自動表示させるかどうか
///
/// 初回起動かつ、アラーム設定ダイアログが表示されていない場合には、自動表示する
final isShowSetNotificationDialogOnLaunchProvider = Provider<bool>((ref) {
  final isFirstLaunch = ref.watch(isFirstLaunchProvider);
  if(!isFirstLaunch) {
    return false;
  }

  final isOpenedFirstLaunchDialog = ref.watch(isOpenedFirstLaunchDialogProvider);
  if(isOpenedFirstLaunchDialog) {
    return false;
  }

  return true;
});

