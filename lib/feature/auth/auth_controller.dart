import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/component/dialog_utils.dart';
import 'package:limited_characters_diary/feature/admob/ad_controller.dart';
import 'package:limited_characters_diary/feature/auth/auth_service.dart';
import 'package:limited_characters_diary/feature/auth/final_confirm_dialog.dart';
import 'package:limited_characters_diary/feature/routing/routing_controller.dart';
import 'package:limited_characters_diary/scaffold_messenger_controller.dart';

import '../../constant/enum.dart';
import '../exception/exception.dart';
import 'confirm_delete_all_data_dialog.dart';

final authControllerProvider = Provider.autoDispose(
  (ref) => AuthController(
    service: ref.watch(authServiceProvider),
    isUserDeletedNotifier: ref.read(isUserDeletedProvider.notifier),
    dialogUtilsController: ref.watch(dialogUtilsControllerProvider),
    scaffoldMessengerController: ref.watch(scaffoldMessengerControllerProvider),
    routingController: ref.watch(routingControllerProvider),
    adController: ref.watch(adControllerProvider),
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
  });

  final AuthService service;
  final StateController<bool> isUserDeletedNotifier;
  final DialogUtilsController dialogUtilsController;
  final ScaffoldMessengerController scaffoldMessengerController;
  final RoutingController routingController;
  final AdController adController;

  /// 匿名ユーザーとしてサインインし、ユーザー情報を追加します。
  ///
  /// この関数は、Firebaseの匿名認証を使用してサインインし、
  /// 成功した場合にユーザー情報を追加する処理を行います。
  ///
  /// エラーが発生した場合は、エラーダイアログを表示します。
  Future<void> signInAnonymouslyAndAddUser() async {
    await _signInAndAddUser(service.signInAnonymouslyAndAddUser);
  }

  /// Googleアカウントを使用してサインインし、ユーザー情報を追加します。
  ///
  /// この関数は、Googleアカウントを使用してFirebaseにサインインし、
  /// 成功した場合にユーザー情報を追加する処理を行います。
  ///
  /// エラーが発生した場合は、エラーダイアログを表示します。
  Future<void> signInGoogleAndAddUser() async {
    await _signInAndAddUser(service.signInGoogleAndAddUser);
  }

  /// Apple IDを使用してサインインし、ユーザー情報を追加します。
  ///
  /// この関数は、Apple IDを使用してFirebaseにサインインし、
  /// 成功した場合にユーザー情報を追加する処理を行います。
  ///
  /// エラーが発生した場合は、エラーダイアログを表示します。
  Future<void> signInAppleAndAddUser() async {
    await _signInAndAddUser(service.signInAppleAndAddUser);
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
      // TODO: ローディング
      await signInMethod();
      // 広告トラッキング許可ダイアログ表示
      await adController.requestATT();
      await routingController.goAndRemoveUntilHomePage();
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dialogUtilsController.showErrorDialog(
          errorDetail: _convertToErrorMessageFromErrorCode(e.code),
        );
      });
    } on FirebaseException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dialogUtilsController.showErrorDialog(
          errorDetail: e.message,
        );
      });
    } on AppException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dialogUtilsController.showErrorDialog(
          errorDetail: e.message,
        );
      });
    }
  }

// TODO サインアウト
  Future<void> signOut() async {
    await service.signOut();
  }

  Future<void> deleteUser({required BuildContext context}) async {
    try {
      await service.deleteUser();

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
      await service.linkUserSocialLogin(
        signInMethod: signInMethod,
      );
      scaffoldMessengerController.showSnackBar('連携されました');
    } on FirebaseException catch (e) {
      scaffoldMessengerController.showSnackBarByFirebaseException(e);
    } on AppException catch (e) {
      scaffoldMessengerController.showSnackBarByException(e);
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
      await service.unLinkUserSocialLogin(
        signInMethod: signInMethod,
      );
      scaffoldMessengerController.showSnackBar('連携が解除されました');
    } on FirebaseException catch (e) {
      scaffoldMessengerController.showSnackBarByFirebaseException(e);
    }
  }
}

/// ユーザーデータ削除時には日記入力ダイアログを表示しないように制御するため
final isUserDeletedProvider = StateProvider((ref) => false);
