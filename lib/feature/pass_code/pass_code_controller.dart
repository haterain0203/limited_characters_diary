import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_service.dart';

import '../admob/ad_controller.dart';
import '../local_notification/local_notification_controller.dart';

final passCodeControllerProvider = Provider(
  (ref) {
    //TODO check Controllerにinvalidateを渡すのは不自然か？渡し方に違和感ないか？
    void invalidate() => ref.invalidate(passCodeProvider);
    return PassCodeController(
      service: ref.watch(passCodeServiceProvider),
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

class PassCodeController {
  //TODO check Controllerの引数が肥大化する場合、何かしら改善すべきか？
  PassCodeController({
    required this.service,
    required this.invalidatePassCodeProvider,
    required this.isSetPassCodeLock,
    required this.isShownInterstitialAd,
    required this.isInitialSetNotification,
    required this.isShownInterstitialAdNotifier,
    required this.isInitialSetNotificationNotifier,
  });

  final PassCodeService service;
  final void Function() invalidatePassCodeProvider;
  final bool isSetPassCodeLock;
  final bool isShownInterstitialAd;
  final bool isInitialSetNotification;
  StateController<bool> isShownInterstitialAdNotifier;
  StateController<bool> isInitialSetNotificationNotifier;

  Future<void> savePassCode({
    required String passCode,
    required bool isPassCodeLock,
  }) async {
    //TODO エラーハンドリング
    await service.savePassCode(
      passCode: passCode,
      isPassCodeLock: isPassCodeLock,
    );
    // passCodeProviderの値を再取得
    // パスコード登録orOFFした際、設定を即時反映させるため
    // ここで再取得しないと、次にアプリが新たに起動されるまでパスコードON/OFFが反映されない
    invalidatePassCodeProvider();
  }

  bool shouldShowPassCodeLockWhenInactive() {
    // パスコード設定がOFFなら処理終了（パスコードロックを表示しない）
    if (!isSetPassCodeLock) {
      return false;
    }

    // 全画面広告から復帰した際は処理終了（パスコードロックを表示しない）
    // 全画面広告表示時にinactiveになるが、そのタイミングではパスコードロック画面を表示したくないため
    if (isShownInterstitialAd) {
      return false;
    }

    // 端末の通知設定ダイアログ表示した際は処理終了（パスコードロックを表示しない）
    // 初めて通知設定した際は、端末の通知設定ダイアログによりinactiveになるが、そのタイミングではパスコードロック画面を表示したくないため
    if (isInitialSetNotification) {
      // falseに戻さないと、初めて通知設定した後にinactiveにした際にロック画面が表示されない
      isInitialSetNotificationNotifier.state = false;
      return false;
    }

    return true;
  }
}

//TODO isSetPassCodeLockProviderと役割が重複していないか？
//TODO controller内のshouldShowPassCodeLockと役割が重複している
/// パスコードロック画面を表示するかどうかを管理するProvider
final isShowPassCodeLockPageProvider = StateProvider<bool>((ref) {
  // 初期値は、パスコードロック設定の値
  return ref.watch(isSetPassCodeLockProvider);
});
