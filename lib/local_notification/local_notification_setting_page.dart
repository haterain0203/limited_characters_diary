import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/local_notification/local_notification_controller.dart';
import 'package:sizer/sizer.dart';

class LocalNotificationSettingPage extends HookConsumerWidget {
  const LocalNotificationSettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationTimeFromLocalDB =
        ref.watch(localNotificationTimeFutureProvider);
    //TODO 表示項目少ないので、ページではなくダイアログでもいいかも
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設定'),
      ),
      body: notificationTimeFromLocalDB.when(
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) {
          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(localNotificationTimeFutureProvider);
                  },
                  child: const Text('再読み込み'),
                )
              ],
            ),
          );
        },
        data: (data) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('設定時間に毎日通知、継続をサポートします'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: TextButton(
                  onPressed: () async {
                    final setTime = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 21, minute: 00),
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            alwaysUse24HourFormat: true,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (setTime == null) {
                      return;
                    }
                    ref
                        .read(localNotificationControllerProvider)
                        .setNotificationTime(setTime);
                  },
                  child: Text(
                    ref
                        .watch(localNotificationControllerProvider)
                        .notificationTime
                        .format(context),
                    style: TextStyle(
                      fontSize: 48.sp,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                child: const Text('登録'),
                onPressed: () {
                  ref
                      .read(localNotificationControllerProvider)
                      .scheduledNotification();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
