import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationRepository {
  LocalNotificationRepository({
    required this.flutterLocalNotificationsPlugin,
  });

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> requestPermissions() async {
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

  Future<void> scheduledNotification() async {
    await requestPermissions();
    //TODO 起動時1回でいいはずなので記載箇所を要検討
    tz.initializeTimeZones();
    final timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    print(timeZoneName);
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        // tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        tz.TZDateTime(tz.local, 2023, 4, 2, 8, 56),
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
        matchDateTimeComponents: DateTimeComponents.dateAndTime);
    print(tz.TZDateTime.now(tz.local));
    print('scheduled');
  }
}
