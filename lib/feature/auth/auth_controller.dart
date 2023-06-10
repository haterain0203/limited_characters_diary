import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/auth/auth_service.dart';
import 'package:limited_characters_diary/feature/auth/final_confirm_dialog.dart';

final authControllerProvider = Provider(
  (ref) => AuthController(
    service: ref.read(authServiceProvider),
      isUserDeletedNotifier: ref.read(isUserDeletedProvider.notifier);
  ),
);

class AuthController {
  AuthController({
    required this.service,
    required this.isUserDeletedNotifier
});
  final AuthService service;
  final StateController<bool> isUserDeletedNotifier;

  Future<void> signInAnonymouslyAndAddUser() async {
    await service.signInAnonymouslyAndAddUser();
  }

//TODO サインアウト
//   Future<void> signOut() async {
//     await repo.signOut();
//   }

  Future<void> deleteUser() async {
    await service.deleteUser();
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

  Future<void> showCompletedDeleteDialog({
    required BuildContext context,
  }) async {
    // ユーザーデータ削除時には日記入力ダイアログを表示しないように制御するためにtrueに
    isUserDeletedNotifier.state = true;
    await AwesomeDialog(
      context: context,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      dialogType: DialogType.success,
      title: '全てのデータを削除しました',
      btnOkText: '閉じる',
      btnOkOnPress: () async {
        isUserDeletedNotifier.state = false;
        // アプリの再起動
        await Phoenix.rebirth(context);
      },
    ).show();
  }

}

/// ユーザーデータ削除時には日記入力ダイアログを表示しないように制御するため
final isUserDeletedProvider = StateProvider((ref) => false);

final authInstanceProvider = Provider((ref) => FirebaseAuth.instance);
