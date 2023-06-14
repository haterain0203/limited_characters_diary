import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_controller.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_lock_page.dart';
import 'package:limited_characters_diary/home_page.dart';

/// パスコードロック画面とListPageを切り替えるためのWidget
class PageSwitcher extends HookConsumerWidget {
  const PageSwitcher({
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
      if (ref
          .read(passCodeControllerProvider)
          .shouldShowPassCodeLockWhenInactive()) {
        ref.read(isShowPassCodeLockPageProvider.notifier).state = true;
      }
    });

    final isShowPassCodeLockPage = ref.watch(isShowPassCodeLockPageProvider);
    if (isShowPassCodeLockPage) {
      return const PassCodeLockPage();
    } else {
      return const HomePage();
    }
  }
}