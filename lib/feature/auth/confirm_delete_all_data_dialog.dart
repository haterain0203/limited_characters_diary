import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/component/stadium_border_button.dart';

import 'auth_providers.dart';

class ConfirmDeleteAllDataDialog extends StatelessWidget {
  const ConfirmDeleteAllDataDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('退会する（全データ削除）'),
      content: const Text('退会すると、全てのデータが削除されます。よろしいですか？'),
      actions: [
        StadiumBorderButton(
          onPressed: () {
            Navigator.pop(context);
            _showFinalConfirmDialog(context);
          },
          title: const Text('はい'),
          backgroundColor: Colors.red,
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('いいえ'),
        ),
      ],
    );
  }

  void _showFinalConfirmDialog(BuildContext context) {
    showDialog<AlertDialog>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return HookConsumer(
          builder: (context, ref, child) {
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
                    await ref.read(authControllerProvider).deleteUser();
                    // ユーザーデータ削除時には日記入力ダイアログを表示しないように制御するためにtrueに
                    ref.read(isUserDeletedProvider.notifier).state = true;
                    if (context.mounted) {
                      await _showCompletedDeleteDialog(
                        context: context,
                        ref: ref,
                      );
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
          },
        );
      },
    );
  }

  Future<void> _showCompletedDeleteDialog({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    await AwesomeDialog(
      context: context,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      dialogType: DialogType.success,
      title: '全てのデータを削除しました',
      btnOkText: '閉じる',
      btnOkOnPress: () async {
        ref.read(isUserDeletedProvider.notifier).state = false;
        // アプリの再起動
        await Phoenix.rebirth(context);
      },
    ).show();
  }
}
