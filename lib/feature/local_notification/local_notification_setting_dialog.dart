import 'package:awesome_dialog/awesome_dialog.dart';
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
                    onPressed: () {
                      _setNotification(
                        context: context,
                        savedNotificationTime: data,
                        ref: ref,
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
                      return _setNotification(
                        context: context,
                        savedNotificationTime: data,
                        ref: ref,
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
                      await ref
                          .read(localNotificationControllerProvider)
                          .deleteNotification();
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

  //TODO check ユーザーアクションなのでControllerに記述すべき？
  Future<void> _setNotification({
    required BuildContext context,
    required TimeOfDay? savedNotificationTime,
    required WidgetRef ref,
  }) async {
    final setTime = await showTimePicker(
      context: context,
      initialTime:
          savedNotificationTime ?? const TimeOfDay(hour: 21, minute: 00),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );
    //入力がなければ早期リターン
    if (setTime == null) {
      return;
    }
    //DBに保存されている値と入力された値が同じ場合も早期リターン
    if (setTime == savedNotificationTime) {
      return;
    }
    //初めて通知設定する場合、trueに
    if (savedNotificationTime == null) {
      ref.read(isInitialSetNotificationProvider.notifier).state = true;
    }
    //通知設定
    //設定された時間をSharedPreferencesに保存
    await ref
        .read(localNotificationControllerProvider)
        .setNotification(setTime);
    if (context.mounted) {
      await _showSetCompleteDialog(context, setTime.to24hours());
    }
  }

  Future<void> _showSetCompleteDialog(
    BuildContext context,
    String setTime,
  ) async {
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      title: '$setTimeに通知を設定しました',
      btnOkText: '閉じる',
      btnOkOnPress: () {
        Navigator.pop(context);
      },
    ).show();
  }
}
