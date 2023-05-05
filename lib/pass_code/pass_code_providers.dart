import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/shared_preferences/shared_preferences_providers.dart';
import 'package:limited_characters_diary/pass_code/pass_code.dart';
import 'package:limited_characters_diary/pass_code/pass_code_controller.dart';
import 'package:limited_characters_diary/pass_code/pass_code_repository.dart';

final passCodeRepositoryProvider = Provider(
  (ref) {
    return PassCodeRepository(
      prefs: ref.watch(sharedPreferencesInstanceProvider),
    );
  },
);

final passCodeControllerProvider = Provider(
  (ref) {
    return PassCodeController(
      repo: ref.watch(passCodeRepositoryProvider),
    );
  },
);

final passCodeProvider = Provider<PassCode>((ref) {
  final repo = ref.watch(passCodeRepositoryProvider);
  final passCode = repo.fetchPassCode();
  print('passCode = $passCode');
  return passCode;
});
