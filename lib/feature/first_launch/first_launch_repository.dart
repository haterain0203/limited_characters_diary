import 'package:shared_preferences/shared_preferences.dart';

class FirstLaunchRepository {

  final completedFirstLaunchKey = 'completed_first_launch';

  Future<void> completedFirstLaunch() async {
    //TODO 共通化
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(completedFirstLaunchKey, true);
  }

  Future<bool?> fetchIsFirstLaunch() async {
    //TODO 共通化
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(completedFirstLaunchKey);
  }

}