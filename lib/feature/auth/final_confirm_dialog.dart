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
            // ユーザー情報および匿名認証アカウント削除処理
            await ref.read(authControllerProvider).deleteUser();
            if (!context.mounted) {
              return;
            }
            // ユーザーデータ削除時には日記入力ダイアログを表示しないように制御するためにtrueに
            ref.read(isUserDeletedProvider.notifier).state = true;
            // 削除が完了したことをダイアログ表示
            await ref
                .read(authControllerProvider)
                .showDeleteCompletedDialog(context: context);
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

  //TODO check 共通化
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
