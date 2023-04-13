import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant.dart';
import 'package:limited_characters_diary/date/date_controller.dart';
import 'package:limited_characters_diary/diary/diary_controller.dart';
import 'package:sizer/sizer.dart';

import '../component/stadium_border_button.dart';
import 'diary.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      title: Text(
        '${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日',
      ),
      content: TextField(
        controller: diaryInputController,
        keyboardType: TextInputType.text,
        maxLength: Constant.limitedCharactersNumber,
        onSubmitted: (String text) {
          diaryInputController.text = text;
        },
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.sp),
                child: StadiumBorderButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  title: 'キャンセル',
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.sp),
                child: StadiumBorderButton(
                  onPressed: () {
                    if (diaryInputController.text.isEmpty) {
                      _showErrorDialog(context, '文字が入力されていません');
                      return;
                    }
                    if (widget.diary?.content == diaryInputController.text) {
                      _showErrorDialog(context, '内容が変更されていません');
                      return;
                    }
                    if (widget.diary == null) {
                      ref.read(diaryControllerProvider).addDiary(
                            content: diaryInputController.text,
                            selectedDate: selectedDate,
                          );
                      diaryInputController.clear();
                      _showCompleteDialog(context);
                    } else {
                      ref.read(diaryControllerProvider).updateDiary(
                            diary: widget.diary!,
                            content: diaryInputController.text,
                          );
                      diaryInputController.clear();
                      _showCompleteDialog(context);
                    }
                  },
                  title: '登録',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showErrorDialog(
    BuildContext context,
    String errorMessage,
  ) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      title: errorMessage,
      btnCancelText: '閉じる',
      btnCancelOnPress: () {},
    ).show();
  }

  void _showCompleteDialog(
    BuildContext context,
  ) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      body: Column(
        children: [
          Column(
            children: [
              Text(
                '登録完了！',
                style: TextStyle(fontSize: 16.sp),
              ),
              const SizedBox(
                height: 8,
              ),
              HookConsumer(
                builder: (context, ref, child) {
                  final diaryCountStr = ref.watch(diaryCountProvider).value;
                  return Text(
                    diaryCountStr != null ? '$diaryCountStr個目の記録です' : '',
                    style: TextStyle(fontSize: 14.sp),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      btnOkText: '閉じる',
      btnOkOnPress: () {
        Navigator.pop(context);
      },
    ).show();
  }
}
