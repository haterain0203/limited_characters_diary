import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_controller.dart';

//TODO check グローバルな関数だが問題はあるか？
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
      // 画面を閉じる
      if (context.mounted) {
        Navigator.pop(context);
      }
    },
    onCancelled: () {
      Navigator.pop(context);
    },
    title: const Text('パスコードを登録'),
    confirmTitle: const Text('パスコードの再確認'),
  );
}
