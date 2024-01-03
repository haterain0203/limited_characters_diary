import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/component/stadium_border_button.dart';

import 'auth_controller.dart';

class ConfirmDeleteAllDataDialog extends StatelessWidget {
  const ConfirmDeleteAllDataDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('退会する（全データ削除）'),
      content: const Text(
        '退会すると、全てのデータが削除されます。よろしいですか？\n\n'
        '※ソーシャル連携済みの場合、最初に再ログインが要求されます。再ログイン後、全てのデータが削除されます。',
      ),
      actions: [
        HookConsumer(
          builder: (context, ref, child) => StadiumBorderButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(authControllerProvider)
                  .showFinalConfirmDialog(context);
            },
            title: const Text('はい'),
            backgroundColor: Colors.red,
          ),
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
}
