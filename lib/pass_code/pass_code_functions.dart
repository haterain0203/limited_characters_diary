import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/pass_code/pass_code_providers.dart';

/// パスコードロック画面の表示
Future<void> showScreenLock(BuildContext context) async {
  await screenLock(
    context: context,
    //TODO
    correctString: '1234',
  );
}

/// パスコード登録画面の表示
Future<void> showScreenLockCreate(BuildContext context, WidgetRef ref, bool isPassCodeLock,) async {
  await screenLockCreate(
    context: context,
    onConfirmed: (passCode) async {
      // 確認した値を保存する
      await ref.read(passCodeControllerProvider).savePassCode(passCode);
      await ref
          .read(passCodeControllerProvider)
          .saveIsPassCodeLock(isPassCodeLock: isPassCodeLock);
      ref.invalidate(passCodeProvider);
      // 画面を閉じる
      if(context.mounted) {
        Navigator.pop(context);
      }
    },
    onCancelled: () {
      Navigator.pop(context);
    },
  );
}
