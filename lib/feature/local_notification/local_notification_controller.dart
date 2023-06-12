import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/local_notification/local_notification_service.dart';

import '../../constant/enum.dart';
import 'local_notification_setting_dialog.dart';

final localNotificationControllerProvider = Provider(
  (ref) {
    //TODO check refごと渡さないことを意識し、invalidateを渡す形にしたが、不自然か？
    void invalidate() => ref.invalidate(localNotificationTimeFutureProvider);
    return LocalNotificationController(
      service: ref.watch(localNotificationServiceProvider),
      invalidateLocalNotificationTimeFutureProvider: invalidate,
    );
  },
);

class LocalNotificationController {
  LocalNotificationController({
    required this.service,
    required this.invalidateLocalNotificationTimeFutureProvider,
  });

  final LocalNotificationService service;
  final void Function() invalidateLocalNotificationTimeFutureProvider;

  //TODO エラーハンドリング
  Future<void> setNotification(TimeOfDay setTime) async {
    await service.scheduledNotification(setTime: setTime);
    await service.saveNotificationTime(setTime: setTime);
  }

  //TODO エラーハンドリング
  Future<void> deleteNotification() async {
    await service.deleteNotification();
    // ローカル通知時間の再取得
    // 通知をリセットした際にUIもリセットするため
    invalidateLocalNotificationTimeFutureProvider();
  }

  Future<void> showSetNotificationDialog(BuildContext context) async {
    await showDialog<LocalNotificationSettingDialog>(
      context: context,
      builder: (_) {
        return const LocalNotificationSettingDialog(
          trigger: NotificationDialogTrigger.onFirstLaunch,
        );
      },
    );
  }
}

/// 初めて通知設定したかどうかの管理
///
/// iOSの場合、初めて通知設定する際に端末の通知許可設定が表示される
/// その際アプリがinactiveになるため、パスコードロック画面が表示されてしまう
/// このinactive時にはパスコードロック画面を表示したくないため、初めて通知設定したかどうかをフラグ管理するもの
/// isShowScreenLockProviderにて使用
final isInitialSetNotificationProvider = StateProvider((ref) => false);
