import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_lock_page.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_providers.dart';
import 'package:limited_characters_diary/list_page.dart';

import '../admob/ad_providers.dart';
import '../local_notification/local_notification_providers.dart';

class PassCodeOrListWidget extends HookConsumerWidget {
  const PassCodeOrListWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useOnAppLifecycleStateChange((previous, current) async {
      /// バックグラウンドになったタイミングで、ScreenLockを呼び出す
      ///
      /// 最初はresumedのタイミングで呼び出そうとしたが、一瞬ListPageが表示されてしまうため、
      /// inactiveのタイミングで呼び出すこととしたもの
      if (current == AppLifecycleState.inactive) {
        if(!ref.read(isSetPassCodeLockProvider)) {
          return;
        }

        // 全画面広告から復帰した際は表示しない
        // 全画面広告表示時にinactiveになるが、そのタイミングではパスコードロック画面を表示したくないため
        if (ref.read(isShownInterstitialAdProvider)) {
          return;
        }

        // 初めて通知設定した際は、端末の通知設定ダイアログによりinactiveになるが、その際は表示しない
        // isShowScreenLockProviderにて使用
        if (ref.read(isInitialSetNotificationProvider)) {
          // falseに戻さないと、初めて通知設定した後にinactiveにした際にロック画面が表示されない
          ref.read(isInitialSetNotificationProvider.notifier).state = false;
          return;
        }
        ref.read(isShowScreenLockProvider.notifier).state = true;
      }
    });

    final isShownPassCodeScreen = ref.watch(isShowScreenLockProvider);
    if (isShownPassCodeScreen) {
      return const PassCodeLockPage();
    } else {
      return const ListPage();
    }
  }
}
