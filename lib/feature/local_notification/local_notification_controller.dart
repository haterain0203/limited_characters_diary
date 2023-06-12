import 'package:flutter/material.dart';
import 'package:limited_characters_diary/feature/local_notification/local_notification_repository.dart';
import 'package:limited_characters_diary/feature/local_notification/local_notification_service.dart';

import '../../constant/enum.dart';
import 'local_notification_setting_dialog.dart';

class LocalNotificationController {
  LocalNotificationController({
    required this.localNotificationService,
    required this.localNotificationSharedPreferencesRepository,
    required this.invalidateLocalNotificationTimeFutureProvider,
  });

  //TODO check Repositoryが2つあるのはおかしい？
  final LocalNotificationService localNotificationRepository;
  final LocalNotificationSharedPreferencesRepository
      localNotificationSharedPreferencesRepository;
  final void Function() invalidateLocalNotificationTimeFutureProvider;

  //TODO エラーハンドリング
  Future<void> scheduledNotification(TimeOfDay setTime) async {
    await localNotificationRepository.scheduledNotification(
      notificationTime: setTime,
    );
  }

  //TODO エラーハンドリング
  Future<void> saveNotificationTime(TimeOfDay notificationTime) async {
    await localNotificationSharedPreferencesRepository
        .saveNotificationTime(notificationTime);
  }

  //TODO エラーハンドリング
  Future<void> deleteNotification() async {
    await localNotificationRepository.deleteNotification();
    await localNotificationSharedPreferencesRepository
        .deleteNotificationTimeStr();
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
