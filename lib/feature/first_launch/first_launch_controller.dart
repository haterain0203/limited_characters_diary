import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/first_launch/first_launch_service.dart';

final firstLaunchControllerProvider = Provider(
  (ref) => FirstLaunchController(
    service: ref.watch(firstLaunchServiceProvider),
  ),
);

class FirstLaunchController {
  FirstLaunchController({required this.service});
  final FirstLaunchService service;

  //TODO エラーハンドリング
  Future<void> completedFirstLaunch() async {
    await service.completedFirstLaunch();
  }
}
