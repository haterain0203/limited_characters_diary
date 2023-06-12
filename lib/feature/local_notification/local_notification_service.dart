import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/local_notification/local_notification_repository.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../constant/constant_num.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (_) {
    //TODO check この方法で問題ないか？
    //main.dartで上書きされる
    throw UnimplementedError();
  },
);

class LocalNotificationService {
  LocalNotificationService({
    required this.repo,
  });

  final LocalNotificationRepository repo;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _initialSetting();
    await _setTimeZone();
  }

  Future<void> _initialSetting() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const initializationSettingsDarwin = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> _setTimeZone() async {
    tz.initializeTimeZones();
    final timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> scheduledNotification({
    required TimeOfDay setTime,
  }) async {
    await _requestPermissions();
    final now = tz.TZDateTime.now(tz.local);
    final dateTimeNotificationTime = DateTime(
      now.year,
      now.month,
      now.day,
      setTime.hour,
      setTime.minute,
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '${ConstantNum.limitedCharactersNumber}文字以内で今日を記録しませんか？',
      '',
      tz.TZDateTime.from(dateTimeNotificationTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      //同じ時間に毎日通知
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<void> saveNotificationTime({required TimeOfDay setTime}) async {
    await repo.saveNotificationTime(setTime);
  }

  Future<void> deleteNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    await repo.deleteNotificationTimeStr();
  }
}

// SharedPreferencesにアクセスし、記録された通知時間の文字列を取得
// TimeOfDayに直して返す
//TODO check autoDisposeの使い所
final localNotificationTimeFutureProvider =
    FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(localNotificationRepoProvider);
  final notificationTimeStr = await repo.fetchNotificationTimeStr();
  if (notificationTimeStr == null) {
    return null;
  }
  final notificationTimeDateTime = DateTime.parse(notificationTimeStr);
  final notificationTime = TimeOfDay.fromDateTime(notificationTimeDateTime);
  return notificationTime;
});
