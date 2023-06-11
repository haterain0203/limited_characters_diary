import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared_preferences/shared_preferences_providers.dart';

final firstLaunchRepositoryProvider = Provider(
  (ref) => FirstLaunchRepository(
    prefs: ref.watch(sharedPreferencesInstanceProvider),
  ),
);

class FirstLaunchRepository {
  FirstLaunchRepository({required this.prefs});
  final SharedPreferences prefs;

  final completedFirstLaunchKey = 'completed_first_launch';

  Future<void> completedFirstLaunch() async {
    await prefs.setBool(completedFirstLaunchKey, true);
  }

  // Future<bool?> fetchIsCompletedFirstLaunch() async {
  //   return prefs.getBool(completedFirstLaunchKey);
  // }
}
