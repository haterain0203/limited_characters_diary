import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_service.dart';

import '../admob/ad_controller.dart';
import '../local_notification/local_notification_controller.dart';

final passCodeControllerProvider = Provider(
  (ref) {
    void invalidate() => ref.invalidate(passCodeProvider);
    return PassCodeController(
      service: ref.watch(passCodeServiceProvider),
      invalidatePassCodeProvider: invalidate,
      passCodeToggle: ref.watch(passCodeLockToggleProvider),
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
  PassCodeController({
    required this.service,
    required this.invalidatePassCodeProvider,
    required this.passCodeToggle,
    required this.isShownInterstitialAd,
    required this.isShownInterstitialAdNotifier,
    required this.isInitialSetNotification,
    required this.isInitialSetNotificationNotifier,
  });

  final PassCodeService service;
  final void Function() invalidatePassCodeProvider;
  final bool passCodeToggle;
  final bool isShownInterstitialAd;
  final StateController<bool> isShownInterstitialAdNotifier;
  final bool isInitialSetNotification;
  final StateController<bool> isInitialSetNotificationNotifier;

  /// 設定画面におけるパスコード設定のトグル切り替え
  ///
  /// トグルの値がtrue→falseならpassCodeを空文字、isPassCodeをfalse、パスコードロックOFF
  /// false→trueならパスコード登録画面を表示、パスコードを登録、パスコードロックON
  Future<void> onPassCodeToggle({
    required bool isPassCodeLock,
    required BuildContext context,
  }) async {
    if (!isPassCodeLock) {
      await _clearPassCode();
      // passCodeProviderの値を再取得
      // パスコード登録orOFFした際、設定を即時反映させるため
      // ここで再取得しないと、次にアプリが新たに起動されるまでパスコードON/OFFが反映されない
      invalidatePassCodeProvider();
    } else {
      await _showPassCodeLockCreate(
        context: context,
        isPassCodeLock: isPassCodeLock,
      );
    }
  }

  Future<void> _savePassCode({
    required String passCode,
    required bool isPassCodeLock,
  }) async {
    //TODO エラーハンドリング（SharedPreferencesもエラーハンドリング必要か？）
    await service.savePassCode(
      passCode: passCode,
      isPassCodeLock: isPassCodeLock,
    );
  }

  /// パスコードロック設定をOFFにし、パスコードには空文字にして登録する
  Future<void> _clearPassCode() async {
    //TODO エラーハンドリング（SharedPreferencesもエラーハンドリング必要か？）
    await service.savePassCode(
      passCode: '',
      isPassCodeLock: false,
    );
  }

  /// パスコード登録画面の表示とパスコードの登録
  Future<void> _showPassCodeLockCreate({
    required BuildContext context,
    required bool isPassCodeLock,
  }) async {
    await screenLockCreate(
      context: context,
      onConfirmed: (passCode) async {
        // Confirmした値を保存する
        await _savePassCode(passCode: passCode, isPassCodeLock: isPassCodeLock);
        // 画面を閉じる
        if (context.mounted) {
          Navigator.pop(context);
        }
        // passCodeProviderの値を再取得
        // パスコード登録orOFFした際、設定を即時反映させるため
        // ここで再取得しないと、次にアプリが新たに起動されるまでパスコードON/OFFが反映されない
        invalidatePassCodeProvider();
      },
      onCancelled: () {
        Navigator.pop(context);
      },
      title: const Text('パスコードを登録'),
      confirmTitle: const Text('パスコードの再確認'),
    );
  }

  bool shouldShowPassCodeLockWhenInactive() {
    // パスコード設定がOFFなら処理終了（パスコードロックを表示しない）
    if (!passCodeToggle) {
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

/// パスコードロック画面を表示するかどうかを管理するProvider
final isShowPassCodeLockPageProvider = StateProvider<bool>((ref) {
  // 初期値は、パスコードロック設定の値
  return ref.watch(passCodeLockToggleProvider);
});
