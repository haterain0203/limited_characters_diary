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
    final savedNotificationTime =
        ref.watch(localNotificationTimeFutureProvider);
    final localNotificationController =
        ref.watch(localNotificationControllerProvider);
    return savedNotificationTime.when(
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
      data: (savedNotificationTime) => AlertDialog(
        //TODO Theme設定でまとめた方が良さそう
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        titlePadding: EdgeInsets.zero,
        title: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: ColoredBox(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  trigger == NotificationDialogTrigger.onFirstLaunch
                      ? 'リマインダーを設定しましょう！'
                      : 'リマインダー設定',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '設定された時間に毎日通知！\n継続をサポートします',
                textAlign: TextAlign.center,
              ),
              savedNotificationTime == null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: StadiumBorderButton(
                        onPressed: () async {
                          await localNotificationController
                              .promptUserAndSetNotification(
                            context: context,
                            savedNotificationTime: null,
                          );
                        },
                        title: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '通知時間を設定する',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: () async {
                        await localNotificationController
                            .promptUserAndSetNotification(
                          context: context,
                          savedNotificationTime: savedNotificationTime,
                        );
                      },
                      child: Text(
                        savedNotificationTime.to24hours(),
                        style: TextStyle(
                          fontSize: 48.sp,
                        ),
                      ),
                    ),
              Visibility(
                visible: savedNotificationTime != null,
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        await localNotificationController.deleteNotification();
                      },
                      child: const Text('リセットする'),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: trigger == NotificationDialogTrigger.userAction,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('閉じる'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
