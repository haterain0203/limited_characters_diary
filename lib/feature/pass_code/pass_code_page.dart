import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_providers.dart';
import 'package:limited_characters_diary/list_page.dart';

class PassCodePage extends HookConsumerWidget {
  const PassCodePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenLock(
      correctString: '1234',
      onUnlocked: () {
        ref.read(isShowScreenLockProvider.notifier).state = false;
      },
    );
  }
}
