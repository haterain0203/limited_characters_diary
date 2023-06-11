import 'package:limited_characters_diary/feature/first_launch/first_launch_repository.dart';

class FirstLaunchService {
  FirstLaunchService({required this.repo});
  final FirstLaunchRepository repo;

  Future<void> completedFirstLaunch() async {
    await repo.completedFirstLaunch();
  }
}
