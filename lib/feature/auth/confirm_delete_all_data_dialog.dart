import 'package:flutter/material.dart';
import 'package:limited_characters_diary/component/stadium_border_button.dart';

class ConfirmDeleteAllDataDialog extends StatelessWidget {
  const ConfirmDeleteAllDataDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('全てのデータ削除'),
      content: const Text('全てのデータを削除します。\nよろしいですか？'),
      actions: [
        TextButton(
          onPressed: () {
            _showFinalConfirmDialog(context);
          },
          child: const Text('はい'),
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
    showDialog<AlertDialog>(context: context, builder: (_) {
      return AlertDialog(
        title: const Text('最終確認'),
        content: const Text('全てのデータを削除します。\n本当によろしいですか？'),
        actions: [
          StadiumBorderButton(
            onPressed: () {
              //TODO 削除処理
            },
            backgroundColor: Colors.red,
            title: const Text('削除する'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('キャンセル'),
          ),
        ],
      );
    },);
  }
}
