import 'package:flutter/material.dart';

class InputDiaryDialog extends StatefulWidget {
  const InputDiaryDialog({super.key});

  @override
  State<InputDiaryDialog> createState() => _InputDiaryDialogState();
}

class _InputDiaryDialogState extends State<InputDiaryDialog> {
  TextEditingController diaryInputController = TextEditingController();

  @override
  void initState() {
    diaryInputController.text = '';
    super.initState();
  }

  @override
  void dispose() {
    diaryInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        keyboardType: TextInputType.text,
        maxLength: 16,
        onSubmitted: (String text) {
          diaryInputController.text = text;
        },
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
