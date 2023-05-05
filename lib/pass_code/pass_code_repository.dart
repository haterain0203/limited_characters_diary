import 'package:shared_preferences/shared_preferences.dart';

class PassCodeRepository {
  PassCodeRepository({required this.prefs});
  final SharedPreferences prefs;

  final passCodeKey = 'pass_code';
  final isPassCodeLockKey = 'is_pass_code_lock';

  Future<void> savePassCode(String passCode) async {
    await prefs.setString(passCode, passCode);
    print('$passCodeで登録しました');
  }

  Future<String?> fetchPassCode() async {
    return prefs.getString(passCodeKey);
  }

  Future<void> saveIsPassCodeLock({required bool isPassCodeLock}) async {
    await prefs.setBool(isPassCodeLockKey, !isPassCodeLock);
  }
}
