import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/diary/diary_service.dart';

import 'diary.dart';
import 'input_diary_dialog.dart';

final diaryControllerProvider = Provider(
  (ref) => DiaryController(
    service: ref.watch(diaryServiceProvider),
    // diaryList: ref.watch(diaryStreamProvider).value,
  ),
);

class DiaryController {
  DiaryController({
    required this.service,
    // this.diaryList,
  });
  final DiaryService service;
  // final List<Diary>? diaryList;

  //TODO エラーハンドリング
  Future<void> addDiary({
    required String content,
    required DateTime selectedDate,
  }) async {
    await service.addDiary(
      content: content,
      selectedDate: selectedDate,
    );
  }

  //TODO エラーハンドリング
  Future<void> updateDiary({
    required Diary diary,
    required String content,
  }) async {
    await service.updateDiary(diary: diary, content: content);
  }

  //TODO エラーハンドリング
  Future<void> deleteDiary({required Diary diary}) async {
    await service.deleteDiary(diary: diary);
  }

  Future<void> showInputDiaryDialog(BuildContext context, Diary? diary) async {
    await showDialog<AlertDialog>(
      context: context,
      builder: (_) {
        return InputDiaryDialog(diary: diary);
      },
    );
  }

  Future<void> showConfirmDeleteDialog({
    required BuildContext context,
    required Diary diary,
  }) async {
    final diaryDateStr =
        '${diary.diaryDate.year}/${diary.diaryDate.month}/${diary.diaryDate.day}';
    await AwesomeDialog(
      //TODO ボタンカラー再検討
      context: context,
      dialogType: DialogType.question,
      title: '$diaryDateStrの\n日記を削除しますか？',
      btnOkColor: Colors.grey,
      btnOkText: 'キャンセル',
      btnOkOnPress: () {},
      btnCancelColor: Colors.red,
      btnCancelText: '削除',
      btnCancelOnPress: () => deleteDiary(diary: diary),
    ).show();
  }
}
