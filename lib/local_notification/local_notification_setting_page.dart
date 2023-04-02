import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/local_notification/local_notification_controller.dart';
import 'package:sizer/sizer.dart';

class LocalNotificationSettingPage extends HookConsumerWidget {
  const LocalNotificationSettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //TODO 表示項目少ないので、ページではなくダイアログでもいいかも
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設定'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('設定時間に毎日通知、継続をサポートします'),
            //TODO 時間設定
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: TextButton(
                onPressed: () async {
                  await showTimePicker(
                    context: context,
                    //TODO 固定値
                    initialTime: const TimeOfDay(hour: 21, minute: 00),
                  );
                },
                child: Text(
                  //TODO 固定値
                  '21:00',
                  style: TextStyle(
                    fontSize: 48.sp,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              child: const Text('登録'),
              onPressed: () {
                //TODO 通知パーミッション確認
                //TODO 通知スケジュール設定
                ref
                    .read(localNotificationControllerProvider)
                    .scheduledNotification();
              },
            ),
          ],
        ),
      ),
    );
  }
}
