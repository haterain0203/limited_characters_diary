import 'package:limited_characters_diary/pass_code/pass_code.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PassCodeRepository {
  PassCodeRepository({required this.prefs});

  final SharedPreferences prefs;

  final passCodeKey = 'pass_code';
  final isPassCodeLockKey = 'is_pass_code_lock';

  /// SharedPreferencesに保存されたPassCodeの値を取得し返す
  PassCode fetchPassCode() {
    final passCode = prefs.getString(passCodeKey);
    final isPassCodeLock = prefs.getBool(isPassCodeLockKey);
    print('isPassCodeLock = $isPassCodeLock');
    print('passCode = $passCode');
    return PassCode(
      passCode: passCode ?? '',
      isPassCodeLock: isPassCodeLock ?? false,
    );
  }

  /// PassCodeをSharedPreferencesに保存する
  Future<void> savePassCode(String passCode) async {
    await prefs.setString(passCodeKey, passCode);
    print('$passCodeで登録しました');
  }

  /// パスコードロックのon/offをSharedPreferencesに保存する
  Future<void> saveIsPassCodeLock({required bool isPassCodeLock}) async {
    await prefs.setBool(isPassCodeLockKey, isPassCodeLock);
  }
}
