import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/local_notification/local_notification_providers.dart';
import 'package:limited_characters_diary/feature/shared_preferences/shared_preferences_providers.dart';

import '../admob/ad_providers.dart';
import 'pass_code.dart';
import 'pass_code_controller.dart';
import 'pass_code_repository.dart';


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

  // 既にロック画面が開いていたら表示しない
  if (ref.watch(isOpenedScreenLockProvider)) {
    return false;
  }

  return true;

});
