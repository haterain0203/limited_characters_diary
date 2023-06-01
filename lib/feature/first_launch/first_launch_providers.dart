import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/first_launch/first_launch_controller.dart';
import 'package:limited_characters_diary/feature/first_launch/first_launch_repository.dart';
import 'package:limited_characters_diary/feature/shared_preferences/shared_preferences_providers.dart';

final firstLaunchRepositoryProvider = Provider(
  (ref) => FirstLaunchRepository(
    prefs: ref.watch(sharedPreferencesInstanceProvider),
  ),
);

final firstLaunchControllerProvider = Provider(
  (ref) => FirstLaunchController(
    repo: ref.watch(firstLaunchRepositoryProvider),
  ),
);
