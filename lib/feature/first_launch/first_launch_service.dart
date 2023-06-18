import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/first_launch/first_launch_repository.dart';

final firstLaunchServiceProvider = Provider(
  (ref) => FirstLaunchService(
    repo: ref.watch(firstLaunchRepositoryProvider),
  ),
);

class FirstLaunchService {
  FirstLaunchService({required this.repo});
  final FirstLaunchRepository repo;

  Future<void> completedFirstLaunch() async {
    await repo.completedFirstLaunch();
  }
}
