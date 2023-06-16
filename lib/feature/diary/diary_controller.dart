import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/diary/diary_service.dart';

import '../../constant/enum.dart';
import '../auth/auth_controller.dart';
import '../update_info/update_info_service.dart';
import 'complete_dialog_content.dart';
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

  //TODO ユーザーアクションなのでDiaryControllerに記述すべきか？その場合、どう移行するか確認したい。
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
    //TODO check Dialogを呼び出す際は漏れなくawaitすべきか？他に実行する処理がない場合はawait不要では？
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

//TODO check 記述箇所/記述方法について確認
/// 起動時に日記入力ダイアログを自動表示するかどうか
final shouldShowInputDiaryDialogOnLaunchProvider =
    Provider.autoDispose<bool>((ref) {
  // 既に日記入力ダイアログが表示済みなら日記ダイアログを自動表示しない
  if (ref.watch(hasInputDiaryDialogShownProvider)) {
    return false;
  }

  if (ref.watch(isUserDeletedProvider)) {
    return false;
  }

  // 日記情報がnullの場合=日記情報取得中の場合は、日記入力ダイアログを表示しない
  final diaryList = ref.watch(diaryStreamProvider);
  final shouldForcedUpdate = ref.watch(shouldForcedUpdateProvider);
  final updateInfo = ref.watch(updateInfoProvider);

  if (diaryList is! AsyncData ||
      shouldForcedUpdate is! AsyncData ||
      updateInfo is! AsyncData) {
    return false;
  }

  // 既に当日の日記が入力済みの場合は、日記入力ダイアログを表示しない
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final todayDiary = diaryList.value
      ?.firstWhereOrNull((element) => element.diaryDate == today);
  if (todayDiary != null) {
    return false;
  }

  // メンテナンス中なら日記ダイアログを自動表示しない
  if (updateInfo.value?.isUnderRepair == true) {
    return false;
  }

  // 強制アップデート表示中の場合は日記ダイアログを自動表示しない
  if (shouldForcedUpdate.value == true) {
    return false;
  }

  return true;
});
