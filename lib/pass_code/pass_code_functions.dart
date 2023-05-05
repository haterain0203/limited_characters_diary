import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/pass_code/pass_code_providers.dart';

Future<void> showScreenLock(BuildContext context) async {
  await screenLock(
    context: context,
    //TODO
    correctString: '1234',
  );
}

Future<void> showScreenLockCreate(BuildContext context, WidgetRef ref) async {
  await screenLockCreate(
    context: context,
    //TODO
    onConfirmed: (passCode) async {
      await ref.read(passCodeControllerProvider).savePassCode(passCode);
    }, // store new passcode somewhere here
  );
}
