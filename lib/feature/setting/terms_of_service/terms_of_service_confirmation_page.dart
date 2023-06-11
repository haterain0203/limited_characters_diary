import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/local_notification/local_notification_providers.dart';
import 'package:limited_characters_diary/feature/routing/routing_controller.dart';
import 'package:sizer/sizer.dart';

import '../../admob/ad_controller.dart';
import '../../first_launch/first_launch_controller.dart';

class TermsOfServiceConfirmationPage extends HookConsumerWidget {
  const TermsOfServiceConfirmationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routingController = ref.watch(routingControllerProvider(context));
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
              onPressed: routingController.goTermsOfServiceOnWebView,
              child: const Text('利用規約を確認する'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('利用規約に同意してはじめる'),
              ),
              onPressed: () async {
                //TODO check 複数のコントローラーのメソッドを呼び出しているのでこれらはこれ以上まとめづらいと考えるが問題ないか？
                await ref
                    .read(firstLaunchControllerProvider)
                    .completedFirstLaunch();
                // 広告トラッキング許可ダイアログ表示
                await ref.read(adControllerProvider).requestATT();
                if (!context.mounted) {
                  return;
                }
                await ref
                    .read(localNotificationControllerProvider)
                    .showSetNotificationDialog(context);
                // 通知設定完了後（通知設定ダイアログが閉じたら）、AuthPageへ遷移する
                // 当初は通知設定ダイアログ側でAuthPageへの遷移を記述していたが、それだとローカル通知時間が正しく反映されない
                if (!context.mounted) {
                  return;
                }
                await routingController.goAuthPage();
              },
            ),
          ],
        ),
      ),
    );
  }
}
