import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/diary/sized_list_tile.dart';

import '../../constant/constant.dart';
import '../date/date_controller.dart';
import 'diary.dart';
import 'diary_providers.dart';
import 'input_diary_dialog.dart';

class DiaryList extends HookConsumerWidget {
  const DiaryList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final dateController = ref.watch(dateControllerProvider);
    final diaryList = ref.watch(diaryStreamProvider);

    useOnAppLifecycleStateChange((previous, current) async {
      /// バックグラウンドから復帰時した点の日付とバックグラウンド移行時の日付が異なる場合、値を更新する
      ///
      /// 本日の日付をハイライトさせているが、
      /// アプリをバックグラウンド→翌日にフォアグラウンドに復帰（resume）→アプリは再起動しない場合がある（端末依存）→日付が更新されずにハイライト箇所が正しくならない
      /// 上記の事象へ対応するもの
      if (current == AppLifecycleState.resumed) {
        final now = DateTime.now();
        final nowDate = DateTime(now.year, now.month, now.day);
        // バックグラウンド移行時の日と復帰時の日が一緒の場合は処理終了
        if (ref.read(dateControllerProvider).isToday(nowDate)) {
          return;
        }
        // バックグラウンド復帰時の日付でStateProviderを更新
        ref.read(todayProvider.notifier).update((state) {
          return DateTime(now.year, now.month, now.day);
        });
      }
    });

    useEffect(
      () {
        Future(() async {
          /// 0.5秒待機
          ///
          /// [scrollController.hasClients]と[ref.read(isShowEditDialogOnLaunchProvider]内の
          /// 今日の日付の日記が記録済みかどうか？の判定に少し時間がかかるため、少し待ってから処理を行う
          /// 待つ処理を挟まないと、jumpToの条件判定と、isShowEditDialogOnLaunchProviderの判定が適切に動作しない
          //TODO [milliseconds: 500]と固定値でしているが改善できないか？
          await Future<void>.delayed(const Duration(milliseconds: 500));

          if (!context.mounted) {
            return;
          }

          /// 月の後半になると、初期起動画面で該当日が表示されないことへの対応
          ///
          /// 当月の場合のみ、「SizedListTileの高さ*（当日の日数-5）」分だけスクロールする
          /// -5としているのは、当日を一番上にするよりも当日の4日前まで見れた方が良いと考えたため
          /// ほとんどの端末で15日程度は表示できると考えるため、当日が10日以下の場合はスクロールしない
          if (ref.read(dateControllerProvider).isJumpToAroundToday()) {
            final today = ref.read(todayProvider);
            if (scrollController.hasClients) {
              scrollController
                  .jumpTo(Constant.sizedListTileHeight * (today.day - 5));
            }
          }

          /// 所定条件をクリアしている場合、起動時に日記入力ダイアログを自動表示する
          if (ref.read(isShowEditDialogOnLaunchProvider)) {
            await _showEditDialog(context, null);
            return;
          }

          //当初は、ForcedUpdateDialog及びUnderRepairDialogもここで表現していたが、
          //これらは、Firestore上のtrue/falseで表示非表示を切り替えたく、Stackで対応することとした
          //ここでも「trueになったら表示」はできるが、「falseになったら非表示」をするには別途変数が必要になりそうで、
          //煩雑になると考え、Stackとしたもの。
        });
        return null;
      },
      const [],
    );

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
            itemCount: dateController.daysInMonth(),
            itemBuilder: (BuildContext context, int index) {
              // indexに応じた日付
              final indexDate = dateController.indexToDateTime(index);
              // indexに応じた日記データ
              final diary = dateController.getIndexDateDiary(data, indexDate);
              // indexに応じた曜日文字列
              final dayOfWeekStr = dateController.searchDayOfWeek(indexDate);
              // indexに応じた日付の文字色（土日祝日の場合色がつく）
              final dayStrColor = dateController.choiceDayStrColor(indexDate);
              return SizedHeightListTile(
                //本日はハイライト
                tileColor: dateController.isToday(indexDate)
                    ? Constant.accentColor
                    : null,
                leading: Text(
                  '${indexDate.day}（$dayOfWeekStr）',
                  style: TextStyle(color: dayStrColor),
                ),
                title: Text(
                  diary?.content ?? '',
                ),
                onTap: () async {
                  ref.read(selectedDateProvider.notifier).state = indexDate;
                  await _showEditDialog(context, diary);
                },
                onLongPress: diary == null
                    ? null
                    : () {
                        _showConfirmDeleteDialog(
                          context: context,
                          ref: ref,
                          diary: diary,
                        );
                      },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog(BuildContext context, Diary? diary) async {
    await showDialog<AlertDialog>(
      context: context,
      builder: (_) {
        return InputDiaryDialog(diary: diary);
      },
    );
  }

  void _showConfirmDeleteDialog({
    required BuildContext context,
    required WidgetRef ref,
    required Diary diary,
  }) {
    final diaryDateStr =
        '${diary.diaryDate.year}/${diary.diaryDate.month}/${diary.diaryDate.day}';
    AwesomeDialog(
      //TODO ボタンカラー再検討
      context: context,
      dialogType: DialogType.question,
      title: '$diaryDateStrの\n日記を削除しますか？',
      btnCancelColor: Colors.grey,
      btnCancelText: 'キャンセル',
      btnCancelOnPress: () {},
      btnOkColor: Theme.of(context).primaryColor,
      btnOkText: '削除',
      btnOkOnPress: () {
        ref.read(diaryControllerProvider).deleteDiary(diary: diary);
      },
    ).show();
  }
}
