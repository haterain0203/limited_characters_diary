import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant.dart';
import 'package:sizer/sizer.dart';

import '../../component/stadium_border_button.dart';
import '../admob/ad_providers.dart';
import '../date/date_controller.dart';
import 'diary.dart';
import 'diary_controller.dart';

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
                  onPressed: () async {
                    if (diaryInputController.text.isEmpty) {
                      _showErrorDialog(context, '文字が入力されていません');
                      return;
                    }
                    if (diary?.content == diaryInputController.text) {
                      _showErrorDialog(context, '内容が変更されていません');
                      return;
                    }
                    if (diary == null) {
                      await ref.read(diaryControllerProvider).addDiary(
                            content: diaryInputController.text,
                            selectedDate: selectedDate,
                          );
                      diaryInputController.clear();
                      await _showCompleteDialog(context);
                    } else {
                      ref.read(diaryControllerProvider).updateDiary(
                            diary: diary!,
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

  Future<void> _showCompleteDialog(
    BuildContext context,
  ) async {
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      body: HookConsumer(
        builder: (context, ref, child) {
          final diaryCount = ref.watch(diaryCountProvider);
          return diaryCount.when(
            error: (e, s) => Text(e.toString()),
            loading: CircularProgressIndicator.new,
            data: (data) {
              print('data = $data');
              return Column(
                children: [
                  Text(
                    '登録完了！',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    '$data個目の記録です',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: StadiumBorderButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          if (data % 3 == 0) {
                            await ref
                                .read(adControllerProvider)
                                .showInterstitialAdd();
                          }
                        },
                        title: '閉じる',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              );
            },
          );
        },
      ),
    ).show();
  }
}
