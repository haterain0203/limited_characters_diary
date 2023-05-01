import 'package:shared_preferences/shared_preferences.dart';

class FirstLaunchRepository {
  FirstLaunchRepository({required this.prefs});
  final SharedPreferences prefs;

  final completedFirstLaunchKey = 'completed_first_launch';

  Future<void> completedFirstLaunch() async {
    await prefs.setBool(completedFirstLaunchKey, true);
  }

  Future<bool?> fetchIsCompletedFirstLaunch() async {
    return prefs.getBool(completedFirstLaunchKey);
  }

}
