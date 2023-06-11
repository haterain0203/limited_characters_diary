import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/diary/diary_controller.dart';
import 'package:sizer/sizer.dart';

import '../../component/stadium_border_button.dart';
import '../../constant/constant_num.dart';
import '../date/date_controller.dart';
import 'diary.dart';

class InputDiaryDialog extends HookConsumerWidget {
  const InputDiaryDialog({
    this.diary,
    super.key,
  });

  final Diary? diary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryInputController =
        useTextEditingController(text: diary?.content ?? '');
    final selectedDate = ref.watch(selectedDateTimeProvider);
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      title: Text(
        //TODO 曜日も表示する
        '${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日',
      ),
      content: TextField(
        autofocus: true,
        controller: diaryInputController,
        keyboardType: TextInputType.text,
        maxLength: ConstantNum.limitedCharactersNumber,
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
                  title: const Text('キャンセル'),
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.sp),
                child: StadiumBorderButton(
                  onPressed: () async {
                    await ref.read(diaryControllerProvider).inputDiary(
                          diary: diary,
                          context: context,
                          diaryInputController: diaryInputController,
                          selectedDate: selectedDate,
                        );
                  },
                  title: const Text('登録'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
