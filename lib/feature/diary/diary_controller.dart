import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/diary/diary_service.dart';

import '../auth/auth_controller.dart';
import '../date/date_controller.dart';
import '../update_info/update_info_providers.dart';
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

/// 既に日記入力ダイアログが表示済みかどうか
final isInputDiaryDialogShownProvider = StateProvider((ref) => false);

//TODO check 記述箇所/記述方法について確認
/// 起動時に日記入力ダイアログを自動表示するかどうか
final isShowInputDiaryDialogOnLaunchProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  // 既に日記入力ダイアログが表示済みなら日記ダイアログを自動表示しない
  if (ref.watch(isInputDiaryDialogShownProvider)) {
    return false;
  }

  // 当月以外の月を表示した際は表示しない
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final selectedDate = ref.watch(selectedDateTimeProvider);
  if (today.month != selectedDate.month) {
    return false;
  }

  // 日記情報がnullの場合=日記情報取得中の場合は、日記入力ダイアログを表示しない
  final diaryList = ref.watch(diaryStreamProvider).value;
  if (diaryList == null) {
    return false;
  }

  // 既に当日の日記が入力済みの場合は、日記入力ダイアログを表示しない
  final todayDiary =
      diaryList.firstWhereOrNull((element) => element.diaryDate == today);
  if (todayDiary != null) {
    return false;
  }

  // メンテナンス中なら日記ダイアログを自動表示しない
  if (ref.watch(updateInfoProvider).value?.isUnderRepair == true) {
    return false;
  }

  // 強制アップデート表示中の場合は日記ダイアログを自動表示しない
  if (await ref.watch(forcedUpdateProvider.future)) {
    return false;
  }

  // ユーザーデータ削除時には表示しない
  //TODO check このフラグが必要になる構造自体に問題がありそう
  // ユーザーデータ削除 → userがnullになる → AuthPageがリビルドする → ListPageがreturnされる → ListPageのuseEffectが実行 → 日記入力ダイアログが表示される
  // という流れだが、ユーザー削除は設定画面から行われ、削除時にはListPageが表示されないため（Phoenixによって再起動されるために最終的にはListPageが呼ばれるが）、
  // ListPageが呼び出される流れ自体に問題がありそう
  if (ref.watch(isUserDeletedProvider)) {
    return false;
  }

  //上記条件をクリアしている場合は、ダイアログを表示させる
  return true;
});
