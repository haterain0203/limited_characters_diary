import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/constant.dart';
import 'package:limited_characters_diary/constant/enum.dart';
import 'package:limited_characters_diary/feature/diary/diary_controller.dart';
import 'package:sizer/sizer.dart';

import '../../component/stadium_border_button.dart';
import '../admob/ad_providers.dart';
import '../date/data_providers.dart';
import 'diary.dart';
import 'diary_providers.dart';

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
        autofocus: true,
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
                    await _inputDiary(
                      context,
                      diaryInputController,
                      ref.read(diaryControllerProvider),
                      selectedDate,
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

  Future<void> _inputDiary(
    BuildContext context,
    TextEditingController diaryInputController,
    DiaryController diaryController,
    DateTime selectedDate,
  ) async {
    if (diaryInputController.text.isEmpty) {
      _showErrorDialog(context, '文字が入力されていません');
      return;
    }
    if (diaryInputController.text.length > 16) {
      _showErrorDialog(context, '16文字以内に修正してください');
      return;
    }
    if (diary?.content == diaryInputController.text) {
      _showErrorDialog(context, '内容が変更されていません');
      return;
    }
    // 新規登録(diary == null)なら、新規登録処理を、そうでなければupdate処理を
    if (diary == null) {
      await diaryController.addDiary(
        content: diaryInputController.text,
        selectedDate: selectedDate,
      );
    } else {
      await diaryController.updateDiary(
        diary: diary!,
        content: diaryInputController.text,
      );
    }
    diaryInputController.clear();
    // #62 キーボードを閉じずに登録すると完了後にキーボードが閉じるアクションが入ってしまうため追加
    // 参考 https://zenn.dev/blendthink/articles/d2c96aa333be07
    primaryFocus?.unfocus();
    // 新規登録(diary == null)なら、新規登録完了を示すダイアログを、そうでなければ更新完了のダイアログとを
    if (context.mounted) {
      await _showCompleteDialog(
        context,
        diary == null ? InputDiaryType.add : InputDiaryType.update,
      );
    }
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
    InputDiaryType inputDiaryType,
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
              return Column(
                children: [
                  Text(
                    inputDiaryType == InputDiaryType.add ? '登録完了！' : '更新完了！',
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
                          if (inputDiaryType == InputDiaryType.update) {
                            return;
                          }
                          // 日記の記録数が3の倍数の場合、全画面広告を出す
                          if (data % 3 == 0) {
                            await ref
                                .read(adControllerProvider)
                                .showInterstitialAdd();
                            ref
                                .read(isShownInterstitialAdProvider.notifier)
                                .state = true;
                          }
                        },
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
