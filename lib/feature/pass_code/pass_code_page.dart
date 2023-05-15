import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_providers.dart';

class PassCodePage extends HookConsumerWidget {
  const PassCodePage({super.key});

  //TODO 戻るボタン無効化した方がいいかも
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenLock(
      correctString: ref.watch(
        passCodeProvider.select((value) => value.passCode),),
      onUnlocked: () {
        ref
            .read(isShowScreenLockProvider.notifier)
            .state = false;
      },
      title: const Text('パスコードを入力してください'),
    );
  }
}
