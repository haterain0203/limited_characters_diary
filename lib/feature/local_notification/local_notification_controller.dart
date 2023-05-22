import 'package:flutter/material.dart';
import 'package:limited_characters_diary/feature/local_notification/local_notification_repository.dart';
import 'package:limited_characters_diary/feature/local_notification/local_notification_shared_preferences_repository.dart';

class LocalNotificationController {
  LocalNotificationController({
    required this.localNotificationRepository,
    required this.localNotificationSharedPreferencesRepository,
    required this.invalidateLocalNotificationTimeFutureProvider,
  });

  //TODO Repositoryが2つあるのはおかしい？
  final LocalNotificationRepository localNotificationRepository;
  final LocalNotificationSharedPreferencesRepository
      localNotificationSharedPreferencesRepository;
  final void Function() invalidateLocalNotificationTimeFutureProvider;

  Future<void> scheduledNotification(TimeOfDay setTime) async {
    await localNotificationRepository.scheduledNotification(
        notificationTime: setTime);
  }

  Future<void> saveNotificationTime(TimeOfDay notificationTime) async {
    await localNotificationSharedPreferencesRepository
        .saveNotificationTime(notificationTime);
  }

  Future<void> deleteNotification() async {
    await localNotificationRepository.deleteNotification();
    await localNotificationSharedPreferencesRepository
        .deleteNotificationTimeStr();
    // ローカル通知時間の再取得
    // 通知をリセットした際にUIもリセットするため
    invalidateLocalNotificationTimeFutureProvider();
  }
}
