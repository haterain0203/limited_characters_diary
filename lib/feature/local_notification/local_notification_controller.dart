import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/component/dialog_utils.dart';
import 'package:limited_characters_diary/extension/time_of_day_converter.dart';
import 'package:limited_characters_diary/feature/local_notification/local_notification_service.dart';

import '../../constant/enum.dart';
import 'local_notification_setting_dialog.dart';

final localNotificationControllerProvider = Provider(
  (ref) {
    void invalidate() => ref.invalidate(localNotificationTimeFutureProvider);
    return LocalNotificationController(
      service: ref.watch(localNotificationServiceProvider),
      invalidateLocalNotificationTimeFutureProvider: invalidate,
      isInitialSetNotificationNotifier:
          ref.read(isInitialSetNotificationProvider.notifier),
      dialogUtilsController: ref.watch(dialogUtilsControllerProvider),
    );
  },
);

class LocalNotificationController {
  LocalNotificationController({
    required this.service,
    required this.invalidateLocalNotificationTimeFutureProvider,
    required this.isInitialSetNotificationNotifier,
    required this.dialogUtilsController,
  });

  final LocalNotificationService service;
  final void Function() invalidateLocalNotificationTimeFutureProvider;
  final StateController<bool> isInitialSetNotificationNotifier;
  final DialogUtilsController dialogUtilsController;

  Future<void> setNotification({
    required BuildContext context,
    required TimeOfDay? savedNotificationTime,
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
    //初めて通知設定する場合、trueに(端末の通知許可ダイアログ表示によりinactiveになるが、その際はパスコード画面を表示したくないため)
    //TODO やりたいことは実現できているが、この方法は正しくない懸念あり
    if (savedNotificationTime == null) {
      isInitialSetNotificationNotifier.state = true;
    }
    //通知設定
    try {
      await service.scheduledNotification(setTime: setTime);
    } on Exception catch (e) {
      debugPrint(e.toString());
      return dialogUtilsController.showErrorDialog(
        errorDetail: e.toString(),
      );
    }
    //設定された時間をSharedPreferencesに保存
    try {
      await service.saveNotificationTime(setTime: setTime);
    } on Exception catch (e) {
      debugPrint(e.toString());
      return dialogUtilsController.showErrorDialog(
        errorDetail: e.toString(),
      );
    }
    if (!context.mounted) {
      return;
    }
    await _showSetCompleteDialog(context, setTime.to24hours());
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

  Future<void> deleteNotification() async {
    try {
      await service.deleteNotification();
      // ローカル通知時間の再取得
      // 通知をリセットした際にUIもリセットするため
      invalidateLocalNotificationTimeFutureProvider();
    } on Exception catch (e) {
      debugPrint(e.toString());
      return dialogUtilsController.showErrorDialog(
        errorDetail: e.toString(),
      );
    }
  }

  Future<void> showSetNotificationDialog({
    required BuildContext context,
    required NotificationDialogTrigger trigger,
  }) async {
    await showDialog<LocalNotificationSettingDialog>(
      context: context,
      builder: (_) {
        return LocalNotificationSettingDialog(
          trigger: trigger,
        );
      },
    );
  }
}

/// 初めて通知設定したかどうかの管理
///
/// iOSの場合、初めて通知設定する際に端末の通知許可設定が表示される
/// その際アプリがinactiveになるため、パスコードロック画面が表示されてしまう
/// このinactive時にはパスコードロック画面を表示したくないため、初めて通知設定したかどうかをフラグ管理するもの
/// isShowScreenLockProviderにて使用
final isInitialSetNotificationProvider = StateProvider((ref) => false);
