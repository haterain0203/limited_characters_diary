import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationSharedPreferencesRepository {
  final notificationTimeStrKey = 'notification_time';

  Future<void> saveNotificationTime(TimeOfDay notificationTime) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationTimeStr = notificationTime.toString();
    await prefs.setString(notificationTimeStrKey, notificationTimeStr);
  }

  Future<void> fetchNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.getString(notificationTimeStrKey);
  }
}
