import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/constant.dart';
import 'package:limited_characters_diary/feature/admob/ad_providers.dart';
import 'package:limited_characters_diary/feature/auth/auth_page.dart';
import 'package:limited_characters_diary/feature/first_launch/first_launch_providers.dart';
import 'package:limited_characters_diary/web_view_page.dart';
import 'package:sizer/sizer.dart';

import '../../../constant/enum.dart';
import '../../local_notification/local_notification_setting_dialog.dart';

class TermsOfServiceConfirmationPage extends StatelessWidget {
  const TermsOfServiceConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20.h,
              width: 20.h,
              child: Image.asset('assets/images/icon.png'),
            ),
            const SizedBox(
              height: 36,
            ),
            const Text('アプリを始めるには利用規約の同意が必要です。'),
            TextButton(
              child: const Text('利用規約を確認する'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<WebViewPage>(
                  builder: (context) => const WebViewPage(
                    title: Constant.termsOfServiceStr,
                    url: Constant.termsOfServiceUrl,
                  ),
                ),
              ),
            ),
            HookConsumer(
              builder: (context, ref, child) => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('利用規約に同意してはじめる'),
                ),
                onPressed: () async {
                  await ref
                      .read(firstLaunchControllerProvider)
                      .completedFirstLaunch();
                  // 初回起動か否かを管理するProviderのflagをtrueにする
                  ref.read(isFirstLaunchProvider.notifier).state = true;
                  // 広告トラッキング許可ダイアログ表示
                  await ref.read(adControllerProvider).requestATT();
                  if (context.mounted) {
                    await _showSetNotificationDialog(context);
                    // 通知設定完了後（通知設定ダイアログが閉じたら）、AuthPageへ遷移する
                    // 当初は通知設定ダイアログ側でAuthPageへの遷移を記述していたが、それだとローカル通知時間が正しく反映されない
                    if (!context.mounted) {
                      return;
                    }
                    await Navigator.push(
                      context,
                      MaterialPageRoute<AuthPage>(
                        builder: (_) => const AuthPage(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSetNotificationDialog(BuildContext context) async {
    await showDialog<LocalNotificationSettingDialog>(
      context: context,
      builder: (_) {
        return const LocalNotificationSettingDialog(
          trigger: NotificationDialogTrigger.onFirstLaunch,
        );
      },
    );
  }
}
