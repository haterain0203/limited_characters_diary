import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_controller.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_service.dart';

class PassCodeLockPage extends HookConsumerWidget {
  const PassCodeLockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async => false,
      child: ColoredBox(
        color: Colors.black87,
        child: ScreenLock(
          correctString: ref.watch(
            passCodeProvider.select((value) => value.passCode),
          ),
          onUnlocked: () {
            ref.read(isShowPassCodeLockPageProvider.notifier).state = false;
          },
          title: const Text('パスコードを入力してください'),
        ),
      ),
    );
  }
}
