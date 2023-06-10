import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/extension/date_time_extensions.dart';
import 'package:limited_characters_diary/feature/date/date_controller.dart';
import 'package:limited_characters_diary/feature/diary/diary_controller.dart';
import 'package:limited_characters_diary/feature/diary/sized_list_tile.dart';

import '../../constant/constant_color.dart';
import '../../constant/constant_num.dart';
import '../date/date_providers.dart';
import 'diary.dart';
import 'diary_providers.dart';
import 'input_diary_dialog.dart';

class DiaryList extends HookConsumerWidget {
  const DiaryList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDateTime = ref.watch(selectedDateTimeProvider);
    final dateController = ref.watch(dateControllerProvider);
    final scrollController = useScrollController();
    final diaryList = ref.watch(diaryStreamProvider);
    final isShowInputDiaryDialog =
        ref.watch(isShowInputDiaryDialogOnLaunchProvider);

    /// バックグラウンド復帰時の日付でStateProviderを更新
    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.resumed) {
        ref
            .read(selectedDateTimeProvider.notifier)
            .update((_) => DateTime.now());
      }
    });

    //TODO check Build後に実行する & ダイアログ判定をFutureProviderに変更することで、Future.delayedを削除したが、対応としてどうか？
    /// 所定条件をクリアしている場合、起動時に日記入力ダイアログを自動表示
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (isShowInputDiaryDialog == const AsyncData(true)) {
        await _showInputDiaryDialog(context, null);
        // 日記入力ダイアログが表示済みであることを記録する
        ref.read(isInputDiaryDialogShownProvider.notifier).state = true;
      }

      //当初は、ForcedUpdateDialog及びUnderRepairDialogもここで表現していたが、
      //これらは、Firestore上のtrue/falseで表示非表示を切り替えたく、Stackで対応することとした
      //ここでも「trueになったら表示」はできるが、「falseになったら非表示」をするには別途変数が必要になりそうで、
      //煩雑になると考え、Stackとしたもの。
    });

    /// 当月の場合のみ、「SizedListTileの高さ*（当日の日数-5）」分だけスクロールする
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoJumpToAroundToday(
        dateController: dateController,
        scrollController: scrollController,
        isJumpedToAroundTodayController: ref.read(
          isJumpedToAroundTodayProvider.notifier,
        ),
      );
    });

    return diaryList.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) {
        return Center(
          child: Text(
            error.toString(),
            textAlign: TextAlign.center,
          ),
        );
      },
      data: (data) {
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: ListView.separated(
            controller: scrollController,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                height: 0.5,
              );
            },
            //TODO check extensionの使い方
            itemCount: DateTime.now().daysInMonth(selectedDateTime),
            itemBuilder: (BuildContext context, int index) {
              // indexに応じた日付
              final indexDate = DateTime(
                selectedDateTime.year,
                selectedDateTime.month,
                index + 1,
              );
              // indexの日付に応じた日記
              final diary = data.firstWhereOrNull((diary) {
                return diary.diaryDate == indexDate;
              });
              //TODO check extensionの使い方合ってるか？
              final dayOfWeekStr = DateTime.now().searchDayOfWeek(indexDate);
              // indexに応じた日付の文字色（土日祝日の場合色がつく）
              final dayStrColor = DateTime.now().choiceDayStrColor(indexDate);
              return Slidable(
                // 該当日に日記がある場合のみ動作
                enabled: diary != null,
                endActionPane: ActionPane(
                  extentRatio: 0.15,
                  motion: const BehindMotion(),
                  children: [
                    // 該当行をスライドすると削除ボタンが表示される
                    SlidableAction(
                      onPressed: (_) {
                        //TODO check ダイアログを表示する処理はController側に書くべき？
                        _showConfirmDeleteDialog(
                          context: context,
                          diaryController: ref.read(diaryControllerProvider),
                          // enabled: diary != null を設定しているため、「!」
                          diary: diary!,
                        );
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                    ),
                  ],
                ),
                child: SizedHeightListTile(
                  //本日はハイライト
                  //TODO check extensionの使い方
                  tileColor: DateTime.now().isToday(indexDate)
                      ? ConstantColor.accentColor
                      : null,
                  leading: Text(
                    '${indexDate.day}（$dayOfWeekStr）',
                    style: TextStyle(color: dayStrColor),
                  ),
                  title: Text(
                    diary?.content ?? '',
                  ),
                  onTap: () async {
                    //TODO check ここは素直にindexDateを渡すべきか？
                    ref.read(selectedDateTimeProvider.notifier).state =
                        indexDate;
                    await _showInputDiaryDialog(context, diary);
                  },
                  onLongPress: diary == null
                      ? null
                      : () {
                          _showConfirmDeleteDialog(
                            context: context,
                            diaryController: ref.read(diaryControllerProvider),
                            diary: diary,
                          );
                        },
                ),
              );
            },
          ),
        );
      },
    );
  }

  //TODO メソッド名と呼び出しているダイアログ名が整合していない
  Future<void> _showInputDiaryDialog(BuildContext context, Diary? diary) async {
    await showDialog<AlertDialog>(
      context: context,
      builder: (_) {
        return InputDiaryDialog(diary: diary);
      },
    );
  }

  void _showConfirmDeleteDialog({
    required BuildContext context,
    required DiaryController diaryController,
    required Diary diary,
  }) {
    final diaryDateStr =
        '${diary.diaryDate.year}/${diary.diaryDate.month}/${diary.diaryDate.day}';
    AwesomeDialog(
      //TODO ボタンカラー再検討
      context: context,
      dialogType: DialogType.question,
      title: '$diaryDateStrの\n日記を削除しますか？',
      btnOkColor: Colors.grey,
      btnOkText: 'キャンセル',
      btnOkOnPress: () {},
      btnCancelColor: Colors.red,
      btnCancelText: '削除',
      btnCancelOnPress: () {
        diaryController.deleteDiary(diary: diary);
      },
    ).show();
  }

  /// 当月の場合のみ、「SizedListTileの高さ*（当日の日数-5）」分だけスクロールする
  ///
  /// 月の後半になると、初期起動画面で該当日が表示されないことへの対応
  /// -5としているのは、当日を一番上にするよりも当日の4日前まで見れた方が良いと考えたため
  /// ほとんどの端末で15日程度は表示できると考えるため、当日が10日以下の場合はスクロールしない
  void _autoJumpToAroundToday({
    required DateController dateController,
    required ScrollController scrollController,
    required StateController<bool> isJumpedToAroundTodayController,
  }) {
    if (!dateController.shouldJumpToAroundToday()) {
      return;
    }
    if (!scrollController.hasClients) {
      return;
    }
    scrollController.jumpTo(
      ConstantNum.sizedListTileHeight * (DateTime.now().day - 5),
    );
    isJumpedToAroundTodayController.state = true;
  }
}
