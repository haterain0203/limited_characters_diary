import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_lock_page.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_providers.dart';
import 'package:limited_characters_diary/home_page.dart';

import '../admob/ad_providers.dart';
import '../local_notification/local_notification_providers.dart';

/// パスコードロック画面とListPageを切り替えるためのWidget
class PassCodeLockOrListPageSwitcher extends HookConsumerWidget {
  const PassCodeLockOrListPageSwitcher({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useOnAppLifecycleStateChange((previous, current) async {
      //TODO check inactiveで実行するのが最前か？
      /// バックグラウンドになったタイミングで、ScreenLockを表示を管理するフラグをtrueにする
      ///
      /// 最初はresumedのタイミングで呼び出そうとしたが、一瞬ListPageが表示されてしまうため、
      /// inactiveのタイミングで呼び出すこととしたもの
      if (current == AppLifecycleState.inactive) {
        //TODO check
        // パスコード設定がOFFなら処理終了
        if (!ref.read(isSetPassCodeLockProvider)) {
          return;
        }

        // 全画面広告から復帰した際は処理終了
        // 全画面広告表示時にinactiveになるが、そのタイミングではパスコードロック画面を表示したくないため
        // TODO check 全画面広告以外にもこういったことが今後発生する可能性がある、その度にこういった分岐を増やすのか？
        if (ref.read(isShownInterstitialAdProvider)) {
          return;
        }

        // 初めて通知設定した際は、端末の通知設定ダイアログによりinactiveになるが、その際は処理終了
        if (ref.read(isInitialSetNotificationProvider)) {
          // falseに戻さないと、初めて通知設定した後にinactiveにした際にロック画面が表示されない
          ref.read(isInitialSetNotificationProvider.notifier).state = false;
          return;
        }
        ref.read(isShowScreenLockProvider.notifier).state = true;
      }
    });

    //TODO check 日記画面が写らないようにこういった対応をしたが、適切か？
    final isShownPassCodeScreen = ref.watch(isShowScreenLockProvider);
    if (isShownPassCodeScreen) {
      return const PassCodeLockPage();
    } else {
      return const HomePage();
    }
  }
}
