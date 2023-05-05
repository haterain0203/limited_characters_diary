import 'package:limited_characters_diary/pass_code/pass_code.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PassCodeRepository {
  PassCodeRepository({required this.prefs});

  final SharedPreferences prefs;

  final passCodeKey = 'pass_code';
  final isPassCodeLockKey = 'is_pass_code_lock';

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

  Future<void> savePassCode(String passCode) async {
    await prefs.setString(passCodeKey, passCode);
    print('$passCodeで登録しました');
  }

  Future<void> saveIsPassCodeLock({required bool isPassCodeLock}) async {
    await prefs.setBool(isPassCodeLockKey, isPassCodeLock);
  }
}
