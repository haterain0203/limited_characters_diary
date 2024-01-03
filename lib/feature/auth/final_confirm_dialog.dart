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
      content: const Text(
        '全てのデータを削除します。\n本当によろしいですか？\n\n'
        '※ソーシャル連携済みの場合、最初に再ログインが要求されます。再ログイン後、全てのデータが削除されます。',
      ),
      actions: [
        StadiumBorderButton(
          onPressed: () async {
            isLoading.value = true;
            // ユーザー情報および匿名認証アカウント削除処理
            await ref.read(authControllerProvider).deleteUser(context: context);
            isLoading.value = false;
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
}
