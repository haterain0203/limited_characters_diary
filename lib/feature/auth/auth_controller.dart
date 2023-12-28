import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/component/dialog_utils.dart';
import 'package:limited_characters_diary/feature/auth/auth_service.dart';
import 'package:limited_characters_diary/feature/auth/final_confirm_dialog.dart';
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
  ),
);

class AuthController {
  AuthController({
    required this.service,
    required this.isUserDeletedNotifier,
    required this.dialogUtilsController,
    required this.scaffoldMessengerController,
  });

  final AuthService service;
  final StateController<bool> isUserDeletedNotifier;
  final DialogUtilsController dialogUtilsController;
  final ScaffoldMessengerController scaffoldMessengerController;

  Future<void> signInAnonymouslyAndAddUser() async {
    try {
      await service.signInAnonymouslyAndAddUser();
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      return WidgetsBinding.instance.addPostFrameCallback((_) {
        dialogUtilsController.showErrorDialog(
          errorDetail: _convertToErrorMessageFromErrorCode(e.code),
        );
      });
    } on FirebaseException catch (e) {
      return WidgetsBinding.instance.addPostFrameCallback((_) {
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

  Future<void> deleteUser() async {
    try {
      await service.deleteUser();
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

  /// [SignInMethod] に基づいて、[AuthService] に定義されたソーシャルログインのリンク処理を実行する。
  ///
  /// - `signInMethod` : リンクまたはリンク解除を行うソーシャルログインの方法。
  /// - `userId` : 操作対象のユーザーID。
  Future<void> linkUserSocialLogin({
    required SignInMethod signInMethod,
    // required String userId,
  }) async {
    try {
      await service.linkUserSocialLogin(
        signInMethod: signInMethod,
      );
    } on FirebaseException catch (e) {
      scaffoldMessengerController.showSnackBarByFirebaseException(e);
    } on AppException catch (e) {
      scaffoldMessengerController.showSnackBarByException(e);
    }
  }
}

/// ユーザーデータ削除時には日記入力ダイアログを表示しないように制御するため
final isUserDeletedProvider = StateProvider((ref) => false);
