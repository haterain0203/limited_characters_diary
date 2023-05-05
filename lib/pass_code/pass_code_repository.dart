import 'package:shared_preferences/shared_preferences.dart';

class PassCodeRepository {
  PassCodeRepository({required this.prefs});
  final SharedPreferences prefs;

  final passCodeKey = 'pass_code';

  Future<void> savePassCode(String passCode) async {
    await prefs.setString(passCode, passCode);
    print('$passCodeで登録しました');
  }

  Future<String?> fetchPassCode() async {
    return prefs.getString(passCodeKey);
  }
}
