import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/shared_preferences/shared_preferences_providers.dart';

import '../admob/ad_providers.dart';
import '../local_notification/local_notification_providers.dart';
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
    //TODO check Controllerにinvalidateを渡すのは不自然か？渡し方に違和感ないか？
    void invalidate() => ref.invalidate(passCodeProvider);
    return PassCodeController(
      repo: ref.watch(passCodeRepositoryProvider),
      invalidatePassCodeProvider: invalidate,
      //TODO check 以下3つはref.watchで良いのか？
      isSetPassCodeLock: ref.watch(isSetPassCodeLockProvider),
      isShownInterstitialAd: ref.watch(isShownInterstitialAdProvider),
      isInitialSetNotification: ref.watch(isInitialSetNotificationProvider),
      isShownInterstitialAdNotifier:
          ref.read(isShownInterstitialAdProvider.notifier),
      isInitialSetNotificationNotifier:
          ref.read(isInitialSetNotificationProvider.notifier),
    );
  },
);

/// PassCodeを取得するProvider
final passCodeProvider = Provider<PassCode>((ref) {
  final repo = ref.watch(passCodeRepositoryProvider);
  final passCode = repo.fetchPassCode();
  return passCode;
});

/// パスコードロック設定をOn/Off状態の取得
final isSetPassCodeLockProvider = Provider<bool>((ref) {
  // 設定でのパスコードロックがOFFなら表示しない
  if (!ref.watch(passCodeProvider.select((value) => value.isPassCodeEnabled))) {
    return false;
  }

  return true;
});

/// パスコードロック画面を表示するかどうかを管理するProvider
final isShowScreenLockProvider = StateProvider<bool>((ref) {
  // 設定でのパスコードロックがOFFなら表示しない
  //TODO return ref.wach(isSetPassCodeLockProvider); で良さそう
  return ref.watch(isSetPassCodeLockProvider);
  if (!ref.watch(isSetPassCodeLockProvider)) {
    return false;
  }

  return true;
});
