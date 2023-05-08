import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/shared_preferences/shared_preferences_providers.dart';
import 'package:limited_characters_diary/pass_code/pass_code.dart';
import 'package:limited_characters_diary/pass_code/pass_code_controller.dart';
import 'package:limited_characters_diary/pass_code/pass_code_repository.dart';

import '../feature/admob/ad_providers.dart';

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

/// PassCodeを取得するProvider
final passCodeProvider = Provider<PassCode>((ref) {
  final repo = ref.watch(passCodeRepositoryProvider);
  final passCode = repo.fetchPassCode();
  return passCode;
});

final isOpenedScreenLockProvider = StateProvider((ref) => false);

/// パスコードロック画面を表示するかどうかを判定するProvider
final isShowScreenLockProvider = Provider<bool>((ref) {

  // 設定でのパスコードロックがOFFなら表示しない
  if (!ref.watch(passCodeProvider.select((value) => value.isPassCodeEnabled))) {
    return false;
  }

  // 全画面広告から復帰した際は表示しない
  if(ref.watch(isShownInterstitialAdProvider)) {
    return false;
  }

  // 既にロック画面が開いていたら表示しない
  if (ref.watch(isOpenedScreenLockProvider)) {
    return false;
  }

  return true;

});
