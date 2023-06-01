import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'pass_code_repository.dart';

class PassCodeController {
  PassCodeController({
    required this.repo,
    required this.invalidatePassCodeProvider,
    required this.isSetPassCodeLock,
    required this.isShownInterstitialAd,
    required this.isInitialSetNotification,
    required this.isShownInterstitialAdNotifier,
    required this.isInitialSetNotificationNotifier,
  });

  final PassCodeRepository repo;
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
    await repo.savePassCode(
      passCode: passCode,
      isPassCodeLock: isPassCodeLock,
    );
    // passCodeProviderの値を再取得
    // パスコード登録orOFFした際、設定を即時反映させるため
    // ここで再取得しないと、次にアプリが新たに起動されるまでパスコードON/OFFが反映されない
    invalidatePassCodeProvider();
  }

  bool shouldShowPassCodeLock() {
    // パスコード設定がOFFなら処理終了
    if (!isSetPassCodeLock) {
      return false;
    }

    // 全画面広告から復帰した際は処理終了
    // 全画面広告表示時にinactiveになるが、そのタイミングではパスコードロック画面を表示したくないため
    //TODO check 全画面広告を閉じて以降、アプリをバックグラウンドに移動させた際、パスコードロックが正しく表示されない
    if (isShownInterstitialAd) {
      return false;
    }

    // 初めて通知設定した際は、端末の通知設定ダイアログによりinactiveになるが、その際は処理終了
    if (isInitialSetNotification) {
      // falseに戻さないと、初めて通知設定した後にinactiveにした際にロック画面が表示されない
      isInitialSetNotificationNotifier.state = false;
      return false;
    }

    return true;
  }
}
