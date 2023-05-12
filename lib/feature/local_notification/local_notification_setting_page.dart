import 'package:flutter/material.dart';
import 'package:limited_characters_diary/constant/enum.dart';

import 'local_notification_setting_dialog.dart';

class LocalNotificationSettingPage extends StatelessWidget {
  const LocalNotificationSettingPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _showSetNotificationDialog(context);
    });
    return const SizedBox.expand(child: ColoredBox(color: Colors.white));
  }

  Future<void> _showSetNotificationDialog(BuildContext context) async {
    await showDialog<LocalNotificationSettingDialog>(
      context: context,
      builder: (_) {
        return const LocalNotificationSettingDialog(
          trigger: NotificationDialogTrigger.autoOnFirstLaunch,
        );
      },
    );
  }
}
