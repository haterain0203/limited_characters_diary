import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/constant_log_event_name.dart';
import 'package:limited_characters_diary/feature/analytics/analytics_controller.dart';
import 'package:limited_characters_diary/feature/routing/routing_controller.dart';
import 'package:sizer/sizer.dart';

import '../../admob/ad_controller.dart';
import '../../first_launch/first_launch_controller.dart';

class TermsOfServiceConfirmationPage extends HookConsumerWidget {
  const TermsOfServiceConfirmationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20.h,
              width: 20.h,
              //TODO flutter_genの導入
              child: Image.asset('assets/images/icon.png'),
            ),
            const SizedBox(
              height: 36,
            ),
            const Text('アプリを始めるには利用規約の同意が必要です。'),
            TextButton(
              onPressed:
                  ref.read(routingControllerProvider).goTermsOfServiceOnWebView,
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
                await ref
                    .read(firstLaunchControllerProvider)
                    .completedFirstLaunch();
                // analyticsにイベント送信
                await ref
                    .read(analyticsContollerProvider)
                    .sendLogEvent(ConstantLogEventName.agreeWithTerms);
                // 広告トラッキング許可ダイアログ表示
                await ref.read(adControllerProvider).requestATT();
                await ref.read(routingControllerProvider).goAuthPage();
              },
            ),
          ],
        ),
      ),
    );
  }
}
