import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// main.dartで上書き処理するため、初期値はUnimplementedError
final sharedPreferencesInstanceProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);
