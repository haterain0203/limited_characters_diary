import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/local_notification/local_notification_repository.dart';

final flutterLocalNotificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>(
  (ref) => throw UnimplementedError(),
);

final localNotificationControllerProvider = Provider(
  (ref) => LocalNotificationController(ref: ref),
);

final localNotificationRepoProvider = Provider((ref) {
  final flutterLocalNotificationsPlugin =
      ref.watch(flutterLocalNotificationsPluginProvider);
  return LocalNotificationRepository(
    flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
  );
});

class LocalNotificationController {
  LocalNotificationController({required this.ref});

  final ProviderRef<dynamic> ref;

  Future<void> scheduledNotification() async {
    final repo = ref.watch(localNotificationRepoProvider);
    await repo.scheduledNotification();
  }
}
