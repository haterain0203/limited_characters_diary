import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/extension/date_time_extensions.dart';
import 'package:limited_characters_diary/feature/date/date_controller.dart';
import 'package:limited_characters_diary/feature/diary/sized_list_tile.dart';

import '../../constant/constant_color.dart';
import 'diary_controller.dart';
import 'diary_service.dart';

class DiaryList extends HookConsumerWidget {
  const DiaryList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDateTime = ref.watch(selectedDateTimeProvider);
    final scrollController = useScrollController();
    final diaryList = ref.watch(diaryStreamProvider);
    final isShowInputDiaryDialog =
        ref.watch(isShowInputDiaryDialogOnLaunchProvider);
    final diaryController = ref.watch(diaryControllerProvider);

    /// バックグラウンド復帰時の日付でStateProviderを更新
    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.resumed) {
        ref
            .read(selectedDateTimeProvider.notifier)
            .update((_) => DateTime.now());
      }
    });

    //TODO check Build後に実行する & ダイアログ判定をFutureProviderに変更することで、Future.delayedを削除したが、、、
    //TODO check Controllerへの移行の仕方（Controllerに移管する場合、多くのProviderをControllerに注入する必要がある）
    /// 所定条件をクリアしている場合、起動時に日記入力ダイアログを自動表示
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (isShowInputDiaryDialog == const AsyncData(true)) {
        await diaryController.showInputDiaryDialog(context, null);
        // 日記入力ダイアログが表示済みであることを記録する
        ref.read(isInputDiaryDialogShownProvider.notifier).state = true;
      }

      //当初は、ForcedUpdateDialog及びUnderRepairDialogもここで表現していたが、
      //これらは、Firestore上のtrue/falseで表示非表示を切り替えたく、Stackで対応することとした
      //ここでも「trueになったら表示」はできるが、「falseになったら非表示」をするには別途変数が必要になりそうで、
      //煩雑になると考え、Stackとしたもの。
    });

    // 特定条件を満たした場合、「SizedListTileの高さ*（当日の日数-5）」分だけ自動スクロールする
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //TODO check 条件次第ではjumpしないため、メソッド名として不適切か？
      //TODO chekc ここではjumpすべきかどうかのboolを返すメソッドにして、View側でjumpToメソッドを呼び出す方が適切か？
      ref.read(dateControllerProvider).jumpToAroundToday(scrollController);
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
            itemCount: selectedDateTime.daysInMonth(),
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
              final dayOfWeekStr = indexDate.dayOfWeek();
              // indexに応じた日付の文字色（土日祝日の場合色がつく）
              final dayStrColor = indexDate.choiceDayStrColor();
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
                        diaryController.showConfirmDeleteDialog(
                          context: context,
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
                  tileColor:
                      indexDate.isToday() ? ConstantColor.accentColor : null,
                  leading: Text(
                    '${indexDate.day}（$dayOfWeekStr）',
                    style: TextStyle(color: dayStrColor),
                  ),
                  title: Text(
                    diary?.content ?? '',
                  ),
                  onTap: () async {
                    //TODO check selectedDateTimeProviderを更新するため、DiaryListが再描画され、カレンダーの一番上が表示されてしまう
                    ref.read(selectedDateTimeProvider.notifier).state =
                        indexDate;
                    await diaryController.showInputDiaryDialog(context, diary);
                  },
                  onLongPress: diary == null
                      ? null
                      : () {
                          diaryController.showConfirmDeleteDialog(
                            context: context,
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
}
