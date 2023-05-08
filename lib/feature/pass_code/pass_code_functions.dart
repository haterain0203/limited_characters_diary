import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'pass_code_providers.dart';

/// パスコードロック画面の表示
Future<void> showScreenLock(
  BuildContext context,
  WidgetRef ref,
) async {
  // パスコード画面を開いたことを示すためにtrueに
  ref.read(isOpenedScreenLockProvider.notifier).state = true;
  await screenLock(
    context: context,
    // SharedPreferencesで保存された値
    correctString: ref.read(passCodeProvider.select((value) => value.passCode)),
    canCancel: false,
    title: const Text('パスコードを入力してください'),
    onUnlocked: () {
      // falseに戻さないと、2回目以降にバックグラウンドにした際にパスコードロック画面が開かない
      ref.read(isOpenedScreenLockProvider.notifier).state = false;
      Navigator.pop(context);
    },
  );
}

/// パスコード登録画面の表示とパスコードの登録
Future<void> showScreenLockCreate({
  required BuildContext context,
  required WidgetRef ref,
  required bool isPassCodeLock,
}) async {
  await screenLockCreate(
    context: context,
    onConfirmed: (passCode) async {
      // Confirmした値を保存する
      await ref
          .read(passCodeControllerProvider)
          .savePassCode(passCode: passCode, isPassCodeLock: isPassCodeLock);
      // passCodeProviderの値を再取得
      ref.invalidate(passCodeProvider);
      // 画面を閉じる
      if (context.mounted) {
        Navigator.pop(context);
      }
    },
    onCancelled: () {
      Navigator.pop(context);
    },
    title: const Text('パスコードを登録'),
    confirmTitle: const Text('パスコードの再確認')
  );
}