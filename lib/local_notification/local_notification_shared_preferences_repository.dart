import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationSharedPreferencesRepository {
  final notificationTimeStrKey = 'notification_time';

  Future<void> saveNotificationTime(
      SharedPreferences prefs, TimeOfDay notificationTime) async {
    final notificationTimeStr = notificationTime.toString();
    await prefs.setString(notificationTimeStrKey, notificationTimeStr);
  }

  Future<void> fetchNotificationTime(SharedPreferences prefs) async {
    prefs.getString(notificationTimeStrKey);
  }
}
