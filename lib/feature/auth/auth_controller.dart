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
    service: ref.read(authServiceProvider),
    isUserDeletedNotifier: ref.read(isUserDeletedProvider.notifier),
  ),
);

class AuthController {
  AuthController({required this.service, required this.isUserDeletedNotifier});

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
}

/// ユーザーデータ削除時には日記入力ダイアログを表示しないように制御するため
final isUserDeletedProvider = StateProvider((ref) => false);

final authInstanceProvider = Provider((ref) => FirebaseAuth.instance);
