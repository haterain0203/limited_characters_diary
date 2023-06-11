import 'package:limited_characters_diary/feature/first_launch/first_launch_service.dart';

class FirstLaunchController {
  FirstLaunchController({required this.service});
  final FirstLaunchService service;

  //TODO エラーハンドリング
  Future<void> completedFirstLaunch() async {
    await service.completedFirstLaunch();
  }
}
