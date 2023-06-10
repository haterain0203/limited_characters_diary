import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../component/stadium_border_button.dart';
import 'auth_controller.dart';

class FinalConfirmDialog extends HookConsumerWidget {
  const FinalConfirmDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    if (isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return AlertDialog(
      title: const Text('最終確認'),
      content: const Text('全てのデータを削除します。\n本当によろしいですか？'),
      actions: [
        StadiumBorderButton(
          onPressed: () async {
            isLoading.value = true;
            // 削除処理
            try {
              await ref.read(authControllerProvider).deleteUser();
              if (!context.mounted) {
                return;
              }
              await ref
                  .read(authControllerProvider)
                  .showCompletedDeleteDialog(context: context);
            } on FirebaseAuthException catch (e) {
              //TODO ここのエラーハンドリングはもう少し考えたほうが良さそう
              // 現状だと、CircularProgressIndicatorが表示されて、操作不可になる
              _showErrorDialog(context, e.toString());
            } on FirebaseException catch (e) {
              _showErrorDialog(context, e.toString());
            }
          },
          backgroundColor: Colors.red,
          title: const Text('退会する'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('キャンセル'),
        ),
      ],
    );
  }

  //TODO 共通化
  void _showErrorDialog(BuildContext context, String e) {
    showDialog<AlertDialog>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('エラーが発生しました'),
          content: Text(e),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('閉じる'),
            )
          ],
        );
      },
    );
  }
}
