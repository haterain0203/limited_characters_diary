import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_controller.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_lock_page.dart';
import 'package:limited_characters_diary/home_page.dart';

/// パスコードロック画面とListPageを切り替えるためのWidget
class PassCodeLockOrListPageSwitcher extends HookConsumerWidget {
  const PassCodeLockOrListPageSwitcher({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // バックグラウンドになったタイミングで、ScreenLockを表示を管理するフラグをtrueにする
    //
    // 最初はresumedのタイミングで呼び出そうとしたが、一瞬ListPageが表示されてしまうため、
    // inactiveのタイミングで呼び出すこととしたもの
    useOnAppLifecycleStateChange((previous, current) async {
      if (current != AppLifecycleState.inactive) {
        return;
      }

      //TODO check 常にパスコード画面を表示するか否かを監視する必要はなく、
      //TODO check inactive時に判定すれば良いので、ProviderではなくContollerのメソッドとしたがどうか？
      if (ref.read(passCodeControllerProvider).shouldShowPassCodeLock()) {
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
