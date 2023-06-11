import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/diary/diary_service.dart';
import 'package:sizer/sizer.dart';

import '../../component/stadium_border_button.dart';
import '../../constant/enum.dart';
import '../admob/ad_providers.dart';
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
                          //TODO check ここに限った話ではないが、DialogにDialogを重ねるのは問題ないか？
                          Navigator.pop(context);
                          Navigator.pop(context);
                          // 更新の場合全画面広告は表示しない
                          if (inputDiaryType == InputDiaryType.update) {
                            return;
                          }
                          // 日記の記録数が3の倍数の場合、全画面広告を出す
                          if (data % 3 == 0) {
                            await ref
                                .read(adControllerProvider)
                                .showInterstitialAdd();
                            //TODO check 以下の処理はController内に記述すべきか？
                            //TODO Controllerのメソッドの責務が2つになってしまうため望ましくないか？
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
