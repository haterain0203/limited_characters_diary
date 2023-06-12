import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/shared_preferences/shared_preferences_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localNotificationRepoProvider = Provider<LocalNotificationRepository>(
  (ref) => LocalNotificationRepository(
    prefs: ref.watch(sharedPreferencesInstanceProvider),
  ),
);

class LocalNotificationRepository {
  LocalNotificationRepository({required this.prefs});

  final SharedPreferences prefs;

  final notificationTimeStrKey = 'notification_time';

  Future<void> saveNotificationTime(TimeOfDay notificationTime) async {
    final now = DateTime.now();
    final notificationDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      notificationTime.hour,
      notificationTime.minute,
    );
    final notificationTimeStr = notificationDateTime.toString();
    await prefs.setString(notificationTimeStrKey, notificationTimeStr);
  }

  Future<String?> fetchNotificationTimeStr() async {
    return prefs.getString(notificationTimeStrKey);
  }

  Future<void> deleteNotificationTimeStr() async {
    await prefs.remove(notificationTimeStrKey);
  }
}
