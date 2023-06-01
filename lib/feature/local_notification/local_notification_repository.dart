import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:limited_characters_diary/constant/constant_string.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationRepository {
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

  Future<void> scheduledNotification({
    required TimeOfDay notificationTime,
  }) async {
    await _requestPermissions();
    final now = tz.TZDateTime.now(tz.local);
    final dateTimeNotificationTime = DateTime(
      now.year,
      now.month,
      now.day,
      notificationTime.hour,
      notificationTime.minute,
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '${Constant.limitedCharactersNumber}文字以内で今日を記録しませんか？',
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

  Future<void> deleteNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
