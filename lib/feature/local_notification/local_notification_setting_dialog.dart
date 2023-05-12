import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/component/stadium_border_button.dart';
import 'package:limited_characters_diary/extension/time_of_day_converter.dart';
import 'package:limited_characters_diary/feature/auth/auth_page.dart';
import 'package:limited_characters_diary/list_page.dart';
import 'package:sizer/sizer.dart';
import '../../constant/enum.dart';
import 'local_notification_providers.dart';

class LocalNotificationSettingDialog extends HookConsumerWidget {
  const LocalNotificationSettingDialog({
    required this.trigger,
    super.key,
  });

  final NotificationDialogTrigger trigger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationTimeFromLocalDB =
        ref.watch(localNotificationTimeFutureProvider);
    return notificationTimeFromLocalDB.when(
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
        title: Column(
          children: [
            const SizedBox(
              height: 8,
            ),
            Text(
              '通知時間を設定してください',
              style: TextStyle(fontSize: 14.sp),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              '設定時間に毎日通知して\n継続をサポートします',
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () async => _setNotification(
                context,
                data,
                ref,
              ),
              child: data?.to24hours() == null
                  ? Text(
                      'ここをタップして\n時間を設定',
                      style: TextStyle(
                        fontSize: 18.sp,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      data!.to24hours(),
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
                      await ref.read(localNotificationControllerProvider).deleteNotification();
                      ref.invalidate(localNotificationTimeFutureProvider);
                    },
                    child: const Text('通知設定をリセットする'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16,),
            // ダイアログが呼び出されたタイミングが初回起動時かどうかで処理を分岐
            trigger == NotificationDialogTrigger.autoOnFirstLaunch
                ? TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('あとで設定する'),
                  )
                : const StadiumBorderButton(),
          ],
        ),
      ),
    );
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

  Future<void> _setNotification(
    BuildContext context,
    TimeOfDay? data,
    WidgetRef ref,
  ) async {
    final setTime = await showTimePicker(
      context: context,
      initialTime: data ?? const TimeOfDay(hour: 21, minute: 00),
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
    if (setTime == data) {
      return;
    }
    //初めて通知設定する場合、trueに
    //
    if (data == null) {
      ref.read(isInitialSetNotificationProvider.notifier).state = true;
    }
    //通知設定
    await ref
        .read(localNotificationControllerProvider)
        .scheduledNotification(setTime);
    //設定された時間をSharedPreferencesに保存
    await ref
        .read(localNotificationControllerProvider)
        .saveNotificationTime(setTime);
    if (context.mounted) {
      await _showSetCompleteDialog(context, setTime.to24hours());
    }
  }
}
