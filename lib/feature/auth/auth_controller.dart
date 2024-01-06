import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/component/dialog_utils.dart';
import 'package:limited_characters_diary/feature/admob/ad_controller.dart';
import 'package:limited_characters_diary/feature/auth/auth_service.dart';
import 'package:limited_characters_diary/feature/auth/final_confirm_dialog.dart';
import 'package:limited_characters_diary/feature/loading/loading_notifier.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_controller.dart';
import 'package:limited_characters_diary/feature/routing/routing_controller.dart';
import 'package:limited_characters_diary/scaffold_messenger_controller.dart';

import '../../constant/enum.dart';
import '../exception/exception.dart';
import 'confirm_delete_all_data_dialog.dart';

/// ソーシャル認証用のダイアログを表示したか否かを管理する。
///
/// ソーシャル認証（連携・連携解除）時に、ソーシャル認証のダイアログが表示されるが、
/// その際、アプリがinactiveになりパスコードロック画面が表示されてしまうため、
/// ソーシャル認証用のダイアログ表示にはパスコードロック画面を表示しないようにするために使用するもの。
final isShownSocialAuthDialog = StateProvider((ref) => false);

/// ユーザーデータ削除時には日記入力ダイアログを表示しないように制御するため
final isUserDeletedProvider = StateProvider((ref) => false);

final authControllerProvider = Provider.autoDispose(
  (ref) => AuthController(
    service: ref.watch(authServiceProvider),
    isUserDeletedNotifier: ref.read(isUserDeletedProvider.notifier),
    dialogUtilsController: ref.watch(dialogUtilsControllerProvider),
    scaffoldMessengerController: ref.watch(scaffoldMessengerControllerProvider),
    routingController: ref.watch(routingControllerProvider),
    adController: ref.watch(adControllerProvider),
    loadingNotifier: ref.read(loadingNotifierProvider.notifier),
    linkedProviders: ref.watch(linkedProvidersProvider),
    isShownSocialAuthDialog: ref.read(isShownSocialAuthDialog.notifier),
    passCodeController: ref.read(passCodeControllerProvider),
  ),
);

class AuthController {
  AuthController({
    required this.service,
    required this.isUserDeletedNotifier,
    required this.dialogUtilsController,
    required this.scaffoldMessengerController,
    required this.routingController,
    required this.adController,
    required this.loadingNotifier,
    required this.linkedProviders,
    required this.isShownSocialAuthDialog,
    required this.passCodeController,
  });

  final AuthService service;
  final StateController<bool> isUserDeletedNotifier;
  final DialogUtilsController dialogUtilsController;
  final ScaffoldMessengerController scaffoldMessengerController;
  final RoutingController routingController;
  final AdController adController;
  final LoadingNotifier loadingNotifier;
  final List<SignInMethod> linkedProviders;

  /// ソーシャル認証ダイアログ表示時にパスコードロック画面が表示されないよう制御するために使用。
  final StateController<bool> isShownSocialAuthDialog;

  /// [deleteUser] で退会処理時に、パスコードロックをOFFにするために使用する。
  final PassCodeController passCodeController;

  /// 匿名ユーザーとしてサインインし、ユーザー情報を追加します。
  ///
  /// ユーザーに匿名認証における注意事項を示した上で、
  /// Firebaseの匿名認証を使用してサインインし、
  /// 成功した場合にユーザー情報を追加する処理を行います。
  Future<void> signInAnonymouslyAndAddUser() async {
    final result = await dialogUtilsController.showYesNoDialog(
      title: '注意事項',
      desc: '機種変更後にデータを引き続き利用するには、ログインが必要です。'
          'ログインは、利用開始後の設定画面から可能です。',
      buttonNoText: '戻る',
      buttonYesText: '利用開始',
    );
    if (!result) {
      return;
    }
    await _signInAndAddUser(service.signInAnonymouslyAndCreateUserIfNotExist);
  }

  /// Googleアカウントを使用してサインインし、ユーザー情報を追加します。
  ///
  /// この関数は、Googleアカウントを使用してFirebaseにサインインし、
  /// 成功した場合にユーザー情報を追加する処理を行います。
  Future<void> signInGoogleAndAddUser() async {
    await _signInAndAddUser(service.signInGoogleAndCreateUserIfNotExist);
  }

  /// Apple IDを使用してサインインし、ユーザー情報を追加します。
  ///
  /// この関数は、Apple IDを使用してFirebaseにサインインし、
  /// 成功した場合にユーザー情報を追加する処理を行います。
  Future<void> signInAppleAndAddUser() async {
    await _signInAndAddUser(service.signInAppleAndCreateUserIfNotExist);
  }

  /// 指定されたサインインメソッドを使用してユーザーをサインインし、情報を追加します。
  ///
  /// [signInMethod] は、サインイン処理を実行する関数です。
  ///
  /// サインイン処理中に発生したエラーは、FirebaseAuthException、
  /// FirebaseException、AppExceptionの各種例外として処理され、
  /// 適切なエラーダイアログが表示されます。
  ///
  /// - Parameters:
  ///   - signInMethod: サインイン処理を行う関数。
  Future<void> _signInAndAddUser(Future<void> Function() signInMethod) async {
    try {
      loadingNotifier.startLoading();
      await signInMethod();
      // 広告トラッキング許可ダイアログ表示
      await adController.requestATT();
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dialogUtilsController.showErrorDialog(
          errorDetail: _convertToErrorMessageFromErrorCode(e.code),
        );
      });
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dialogUtilsController.showErrorDialog(
          errorDetail: e.message,
        );
      });
    } on AppException catch (e) {
      if (e.message == 'キャンセルされました。') {
        scaffoldMessengerController.showSnackBarByException(e);
        return;
      }
      debugPrint(e.toString());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dialogUtilsController.showErrorDialog(
          errorDetail: e.message,
        );
      });
    } finally {
      loadingNotifier.endLoading();
    }
  }

// TODO サインアウト
  Future<void> signOut() async {
    await service.signOut();
  }

  Future<void> deleteUser({required BuildContext context}) async {
    try {
      loadingNotifier.startLoading();

      // ソーシャル認証ダイアログ表示時にパスコードロック画面が表示されないよう制御
      // TODO: 直書きではなく、Notifierなどを活用して関数化すべき（他の箇所も同様）
      isShownSocialAuthDialog.state = true;

      await service.deleteUser();

      // `showDeleteCompletedDialog` の前にローディングを止めないと、
      // `showDeleteCompletedDialog` の上にローディングが表示され続けてしまい、
      // `showDeleteCompletedDialog` の「閉じる」を押下させられない
      loadingNotifier.endLoading();

      // 退会処理完了後、パスコードロックをOFFにする。
      // これをしない場合、退会処理後しばらくしてからそのユーザーが再度アプリを使用しようとした際に、パスコードロックがかかってしまう。
      // もしパスコードロック番号を忘れていた場合アプリが使用できないため、退会処理時にOFFにするもの。
      await passCodeController.disablePassCodeLock();

      // ユーザーデータ削除時には日記入力ダイアログを表示しないように制御するためにtrueに
      isUserDeletedNotifier.state = true;

      // 削除が完了したことをダイアログ表示
      if (!context.mounted) {
        return;
      }
      await showDeleteCompletedDialog(context: context);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      return WidgetsBinding.instance.addPostFrameCallback((_) {
        dialogUtilsController.showErrorDialog(
          errorDetail: _convertToErrorMessageFromErrorCode(e.code),
        );
      });
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
      return WidgetsBinding.instance.addPostFrameCallback((_) {
        dialogUtilsController.showErrorDialog(
          errorDetail: e.message,
        );
      });
    } on AppException catch (e) {
      scaffoldMessengerController.showSnackBarByException(e);
    } finally {
      // ソーシャル認証ダイアログ表示時にパスコードロック画面が表示されないための制御を解除
      isShownSocialAuthDialog.state = false;
      loadingNotifier.endLoading();
    }
  }

  Future<void> showConfirmDeleteAllDataDialog(BuildContext context) async {
    await showDialog<ConfirmDeleteAllDataDialog>(
      context: context,
      builder: (_) {
        return const ConfirmDeleteAllDataDialog();
      },
    );
  }

  Future<void> showFinalConfirmDialog(BuildContext context) async {
    await showDialog<FinalConfirmDialog>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const FinalConfirmDialog();
      },
    );
  }

  Future<void> showDeleteCompletedDialog({
    required BuildContext context,
  }) async {
    await AwesomeDialog(
      context: context,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      dialogType: DialogType.success,
      title: '全てのデータを削除しました',
      btnOkText: '閉じる',
      btnOkOnPress: () async {
        // アプリの再起動
        await Phoenix.rebirth(context);
        isUserDeletedNotifier.state = false;
      },
    ).show();
  }

  String _convertToErrorMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case 'email-already-exists':
        return '指定されたメールアドレスは既に使用されています。';
      case 'wrong-password':
        return 'パスワードが違います。';
      case 'invalid-email':
        return 'メールアドレスが不正です。';
      case 'user-not-found':
        return '指定されたユーザーは存在しません。';
      case 'user-disabled':
        return '指定されたユーザーは無効です。';
      case 'operation-not-allowed':
        return '指定されたユーザーはこの操作を許可していません。';
      case 'too-many-requests':
        return '指定されたユーザーはこの操作を許可していません。';
      default:
        return '不明なエラーが発生しました。';
    }
  }

  /// ソーシャル認証の連携処理を行う。
  ///
  /// [SignInMethod] に基づいて、[AuthService] に定義されたソーシャルログインのリンク処理を実行する。
  /// 処理が完了した際は、ユーザーにその旨を通知する。
  ///
  /// - `signInMethod` : リンクまたはリンク解除を行うソーシャルログインの方法。
  Future<void> linkUserSocialLogin({
    required SignInMethod signInMethod,
  }) async {
    try {
      loadingNotifier.startLoading();
      // ソーシャル認証ダイアログ表示時にパスコードロック画面が表示されないよう制御
      isShownSocialAuthDialog.state = true;
      await service.linkUserSocialLogin(
        signInMethod: signInMethod,
      );
      scaffoldMessengerController.showSnackBar('連携されました');
    } on FirebaseException catch (e) {
      scaffoldMessengerController.showSnackBarByFirebaseException(e);
    } on AppException catch (e) {
      scaffoldMessengerController.showSnackBarByException(e);
    } finally {
      // ソーシャル認証ダイアログ表示時にパスコードロック画面が表示されないための制御を解除
      isShownSocialAuthDialog.state = false;
      loadingNotifier.endLoading();
    }
  }

  /// ソーシャル認証連携の解除処理を行う。
  ///
  /// ソーシャル認証連携が有効化されている場合、指定された [SignInMethod] に基づいて、
  /// [AuthService] に定義されたソーシャルログインのリンク解除処理を実行する。
  /// 処理が完了した際は、ユーザーにその旨を通知する。
  ///
  /// - [signInMethod] : リンクまたはリンク解除を行うソーシャルログインの方法。
  Future<void> unLinkUserSocialLogin({
    required SignInMethod signInMethod,
  }) async {
    try {
      // 解除しようとしている連携が唯一のものである場合、解除不可の旨を通知し、処理を終了する。
      if (linkedProviders.length == 1) {
        return dialogUtilsController.showErrorDialog(
          errorDetail: '唯一の認証連携のため解除できません。\n少なくとも1つの連携が必要です。',
        );
      }

      // ユーザーに連携解除の確認を求める。
      final result = await dialogUtilsController.showYesNoDialog(
        desc: '${signInMethod.displayName}連携を解除しますか？',
        buttonYesText: '連携解除',
      );
      // 回答がNOなら処理終了。
      if (!result) {
        return;
      }

      loadingNotifier.startLoading();
      // ソーシャル認証ダイアログ表示時にパスコードロック画面が表示されないよう制御
      isShownSocialAuthDialog.state = true;
      await service.unLinkUserSocialLogin(
        signInMethod: signInMethod,
      );
      scaffoldMessengerController.showSnackBar('連携が解除されました');
    } on FirebaseException catch (e) {
      scaffoldMessengerController.showSnackBarByFirebaseException(e);
    } finally {
      // ソーシャル認証ダイアログ表示時にパスコードロック画面が表示されないための制御を解除
      isShownSocialAuthDialog.state = false;
      loadingNotifier.endLoading();
    }
  }
}
