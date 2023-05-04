import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';

Future<void> showScreenLock(BuildContext context) async {
  await screenLock(
    context: context,
    //TODO
    correctString: '1234',
  );
}

Future<void> showScreenLockCreate(BuildContext context) async {
  await screenLockCreate(
    context: context,
    //TODO
    onConfirmed: (value) => print(value), // store new passcode somewhere here
  );
}
