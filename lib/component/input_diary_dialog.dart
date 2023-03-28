import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/date/date_controller.dart';
import 'package:limited_characters_diary/diary/diary_controller.dart';

import '../diary/collection/diary.dart';

class InputDiaryDialog extends StatefulHookConsumerWidget {
  const InputDiaryDialog({
    this.diary,
    super.key,
  });

  final Diary? diary;
  @override
  ConsumerState<InputDiaryDialog> createState() => _InputDiaryDialogState();
}

class _InputDiaryDialogState extends ConsumerState<InputDiaryDialog> {
  TextEditingController diaryInputController = TextEditingController();

  @override
  void initState() {
    diaryInputController.text = widget.diary?.content ?? '';
    super.initState();
  }

  @override
  void dispose() {
    diaryInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    return AlertDialog(
      title: Text(
        '${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日',
      ),
      content: TextField(
        controller: diaryInputController,
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
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            if (diaryInputController.text.isEmpty) {
              _showAlertDialog(context, '文字が入力されていません');
              return;
            }
            if (widget.diary?.content == diaryInputController.text) {
              _showAlertDialog(context, '内容が変更されていません');
              return;
            }
            if (widget.diary == null) {
              ref.read(diaryControllerProvider).addDiary(
                    content: diaryInputController.text,
                    selectedDate: selectedDate,
                  );
              Navigator.pop(context);
              //TODO AwesomeDialogとか表示したい
            } else {
              ref.read(diaryControllerProvider).updateDiary(
                    diary: widget.diary!,
                    content: diaryInputController.text,
                  );
              Navigator.pop(context);
              //TODO AwesomeDialogとか表示したい
            }
          },
          child: const Text('登録'),
        ),
      ],
    );
  }

  void _showAlertDialog(BuildContext context, String errorMessage) {
    showDialog<AlertDialog>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('エラー'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('閉じる'),
            ),
          ],
        );
      },
    );
  }
}
