import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/auth/auth_service.dart';
import 'package:limited_characters_diary/feature/auth/final_confirm_dialog.dart';

import 'confirm_delete_all_data_dialog.dart';

final authControllerProvider = Provider(
  (ref) => AuthController(
    service: ref.watch(authServiceProvider),
    isUserDeletedNotifier: ref.read(isUserDeletedProvider.notifier),
  ),
);

class AuthController {
  AuthController({
    required this.service,
    required this.isUserDeletedNotifier,
  });

  final AuthService service;
  final StateController<bool> isUserDeletedNotifier;

  Future<void> signInAnonymouslyAndAddUser() async {
    try {
      await service.signInAnonymouslyAndAddUser();
    } on FirebaseAuthException catch (e) {
      //TODO エラーハンドリング
      debugPrint(e.toString());
    } on FirebaseException catch (e) {
      //TODO エラーハンドリング
      debugPrint(e.toString());
    }
  }

//TODO サインアウト
//   Future<void> signOut() async {
//     await repo.signOut();
//   }

  Future<void> deleteUser() async {
    try {
      await service.deleteUser();
    } on FirebaseAuthException catch (e) {
      //TODO dialogでエラーメッセージ表示
      debugPrint(e.toString());
    } on FirebaseException catch (e) {
      //TODO dialogでエラーメッセージ表示
      debugPrint(e.toString());
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

}

/// ユーザーデータ削除時には日記入力ダイアログを表示しないように制御するため
final isUserDeletedProvider = StateProvider((ref) => false);
