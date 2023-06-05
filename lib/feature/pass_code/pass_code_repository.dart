import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pass_code.dart';

class PassCodeRepository {
  PassCodeRepository({required this.prefs});

  final SharedPreferences prefs;

  final passCodeKey = 'pass_code';
  final isPassCodeLockKey = 'is_pass_code_lock';

  /// SharedPreferencesに保存されたPassCodeの値を取得し返す
  PassCode fetchPassCode() {
    final passCode = prefs.getString(passCodeKey);
    final isPassCodeLockEnabled = prefs.getBool(isPassCodeLockKey);
    return PassCode(
      passCode: passCode ?? '',
      isPassCodeEnabled: isPassCodeLockEnabled ?? false,
    );
  }

  /// PassCodeをSharedPreferencesに保存する
  Future<void> savePassCode({
    required String passCode,
    required bool isPassCodeLock,
  }) async {
    await prefs.setString(passCodeKey, passCode);
    await prefs.setBool(isPassCodeLockKey, isPassCodeLock);
    debugPrint(
        'passCode = $passCode\nisPassCodeLock = $isPassCodeLock\nで登録しました');
  }
}
