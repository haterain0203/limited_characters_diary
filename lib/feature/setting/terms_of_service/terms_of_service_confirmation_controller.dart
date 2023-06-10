import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constant/constant_string.dart';
import '../../../constant/enum.dart';
import '../../../web_view_page.dart';
import '../../auth/auth_page.dart';
import '../../local_notification/local_notification_setting_dialog.dart';

final termsOfServiceConfirmationControllerProvider =
    Provider((_) => TermsOfServiceConfirmationController());

class TermsOfServiceConfirmationController {
  void goTermsOfServiceOnWebView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<WebViewPage>(
        builder: (context) => const WebViewPage(
          title: ConstantString.termsOfServiceStr,
          url: ConstantString.termsOfServiceUrl,
        ),
      ),
    );
  }

  Future<void> showSetNotificationDialog(BuildContext context) async {
    await showDialog<LocalNotificationSettingDialog>(
      context: context,
      builder: (_) {
        return const LocalNotificationSettingDialog(
          trigger: NotificationDialogTrigger.onFirstLaunch,
        );
      },
    );
  }

  Future<void> goAuthPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute<AuthPage>(
        builder: (_) => const AuthPage(),
      ),
    );
  }
}
