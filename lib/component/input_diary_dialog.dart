import 'package:flutter/material.dart';

class InputDiaryDialog extends StatefulWidget {
  const InputDiaryDialog({super.key});

  @override
  State<InputDiaryDialog> createState() => _InputDiaryDialogState();
}

class _InputDiaryDialogState extends State<InputDiaryDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        keyboardType: TextInputType.text,
        maxLength: 16,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            //TODO add or edit処理
          },
          child: Text('保存'),
        ),
      ],
    );
  }
}
