import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'local_notification_providers.dart';

class LocalNotificationController {
  LocalNotificationController({required this.ref});

  final ProviderRef<dynamic> ref;

  Future<void> scheduledNotification(TimeOfDay setTime) async {
    final repo = ref.watch(localNotificationRepoProvider);
    await repo.scheduledNotification(notificationTime: setTime);
  }

  Future<void> saveNotificationTime(TimeOfDay notificationTime) async {
    final repo = ref.read(localNotificationSharedRepoProvider);
    await repo.saveNotificationTime(notificationTime);
  }
}
