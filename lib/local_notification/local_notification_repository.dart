import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
}
