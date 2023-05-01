import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/first_launch/first_launch_controller.dart';
import 'package:limited_characters_diary/feature/first_launch/first_launch_repository.dart';

final isFirstLaunchProvider = StateProvider<bool>((_) => false);

final isCompletedFirstLaunchProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(firstLaunchRepositoryProvider);
  final isCompletedFirstLaunch = await repo.fetchIsCompletedFirstLaunch();
  if(isCompletedFirstLaunch == null) {
    return false;
  }
  if(!isCompletedFirstLaunch) {
    return false;
  }
  return true;
});

final firstLaunchRepositoryProvider = Provider(
  (ref) => FirstLaunchRepository(),
);

final firstLaunchControllerProvider = Provider(
  (ref) => FirstLaunchController(
    repo: ref.watch(firstLaunchRepositoryProvider),
  ),
);
