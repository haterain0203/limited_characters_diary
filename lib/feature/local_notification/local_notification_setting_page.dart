import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'local_notification_setting_dialog.dart';

class LocalNotificationSettingPage extends HookConsumerWidget {
  const LocalNotificationSettingPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _showSetNotificationDialog(context);
    });
    return const SizedBox.expand(child: ColoredBox(color: Colors.white));
  }

  Future<void> _showSetNotificationDialog(BuildContext context) async {
    await showDialog<LocalNotificationSettingDialog>(
      context: context,
      builder: (_) {
        return const LocalNotificationSettingDialog();
      },
    );
  }

}
