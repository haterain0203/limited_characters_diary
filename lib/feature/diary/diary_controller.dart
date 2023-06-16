import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/diary/diary_service.dart';

import '../../constant/enum.dart';
import 'complete_dialog_content.dart';
import 'diary.dart';
import 'input_diary_dialog.dart';

final diaryControllerProvider = Provider(
  (ref) => DiaryController(
    service: ref.watch(diaryServiceProvider),
  ),
);

class DiaryController {
  DiaryController({
    required this.service,
  });

  final DiaryService service;

  //TODO エラーハンドリング
  Future<void> _addDiary({
    required String content,
    required DateTime selectedDate,
  }) async {
    await service.addDiary(
      content: content,
      selectedDate: selectedDate,
    );
  }

  //TODO エラーハンドリング
  Future<void> _updateDiary({
    required Diary diary,
    required String content,
  }) async {
    await service.updateDiary(diary: diary, content: content);
  }

  //TODO エラーハンドリング
  Future<void> _deleteDiary({required Diary diary}) async {
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

  //TODO check 肥大化しているが、もっと分割すべきか？
  Future<void> inputDiary({
    required BuildContext context,
    required Diary? diary,
    required TextEditingController diaryInputController,
    required DateTime selectedDate,
  }) async {
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
      await _addDiary(
        content: diaryInputController.text,
        selectedDate: selectedDate,
      );
    } else {
      await _updateDiary(
        diary: diary,
        content: diaryInputController.text,
      );
    }
    diaryInputController.clear();
    // #62 キーボードを閉じずに登録すると完了後にキーボードが閉じるアクションが入ってしまうため追加
    // 参考 https://zenn.dev/blendthink/articles/d2c96aa333be07
    primaryFocus?.unfocus();
    // 新規登録(diary == null)なら、新規登録完了を示すダイアログを、そうでなければ更新完了のダイアログとを
    if (!context.mounted) {
      return;
    }
    await _showCompleteDialog(
      context,
      diary == null ? InputDiaryType.add : InputDiaryType.update,
    );
  }

  //TODO 共通化
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
      body: CompleteDialogContent(inputDiaryType: inputDiaryType),
    ).show();
  }

  Future<void> showConfirmDeleteDialog({
    required BuildContext context,
    required Diary diary,
  }) async {
    //TODO 曜日も表示する
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
      btnCancelOnPress: () => _deleteDiary(diary: diary),
    ).show();
  }
}

/// 既に日記入力ダイアログが表示済みかどうか
final hasInputDiaryDialogShownProvider = StateProvider((ref) => false);
