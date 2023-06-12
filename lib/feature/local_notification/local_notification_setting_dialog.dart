import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/component/stadium_border_button.dart';
import 'package:limited_characters_diary/extension/time_of_day_converter.dart';
import 'package:sizer/sizer.dart';

import '../../constant/enum.dart';
import 'local_notification_controller.dart';
import 'local_notification_service.dart';

class LocalNotificationSettingDialog extends HookConsumerWidget {
  const LocalNotificationSettingDialog({
    required this.trigger,
    super.key,
  });

  final NotificationDialogTrigger trigger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationTime = ref.watch(localNotificationTimeFutureProvider);
    final localNotificationController =
        ref.watch(localNotificationControllerProvider);
    return notificationTime.when(
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
      data: (data) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        title: Text(
          '設定時間に毎日通知して\n継続をサポートします',
          style: TextStyle(fontSize: 14.sp),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            data == null
                ? StadiumBorderButton(
                    onPressed: () async {
                      await localNotificationController.setNotification(
                        context: context,
                        savedNotificationTime: data,
                      );
                    },
                    title: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '通知時間を設定する',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: () async {
                      await localNotificationController.setNotification(
                        context: context,
                        savedNotificationTime: data,
                      );
                    },
                    child: Text(
                      data.to24hours(),
                      style: TextStyle(
                        fontSize: 48.sp,
                      ),
                    ),
                  ),
            Visibility(
              visible: data != null,
              child: Column(
                children: [
                  TextButton(
                    onPressed: () async {
                      await localNotificationController.deleteNotification();
                    },
                    child: const Text('通知設定をリセットする'),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: trigger == NotificationDialogTrigger.onFirstLaunch
                  ? const Text('あとで設定する')
                  : const Text('閉じる'),
            ),
          ],
        ),
      ),
    );
  }
}
