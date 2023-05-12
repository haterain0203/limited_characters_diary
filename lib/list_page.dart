import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/enum.dart';
import 'package:limited_characters_diary/feature/admob/ad_banner.dart';
import 'package:limited_characters_diary/feature/diary/sized_list_tile.dart';
import 'package:limited_characters_diary/feature/update_info/forced_update_dialog.dart';
import 'package:limited_characters_diary/feature/update_info/under_repair_dialog.dart';
import 'constant/constant.dart';
import 'feature/admob/ad_providers.dart';
import 'feature/date/date_controller.dart';
import 'feature/diary/diary.dart';
import 'feature/diary/diary_providers.dart';
import 'feature/diary/input_diary_dialog.dart';
import 'feature/local_notification/local_notification_providers.dart';
import 'feature/local_notification/local_notification_setting_dialog.dart';
import 'feature/pass_code/pass_code_functions.dart';
import 'feature/pass_code/pass_code_providers.dart';
import 'feature/setting/setting_page.dart';

class ListPage extends HookConsumerWidget {
  const ListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();

    useOnAppLifecycleStateChange((previous, current) async {
      /// バックグラウンドになったタイミングで、ScreenLockを呼び出す
      ///
      /// 最初はresumedのタイミングで呼び出そうとしたが、一瞬ListPageが表示されてしまうため、
      /// inactiveのタイミングで呼び出すこととしたもの
      if (current == AppLifecycleState.inactive) {
        // 全画面広告から復帰した際は表示しない
        // 全画面広告表示時にinactiveになるが、そのタイミングではパスコードロック画面を表示したくないため
        if (ref.read(isShownInterstitialAdProvider)) {
          return;
        }

        // 初めて通知設定した際は、端末の通知設定ダイアログによりinactiveになるが、その際は表示しない
        // isShowScreenLockProviderにて使用
        if (ref.read(isInitialSetNotificationProvider)) {
          // falseに戻さないと、初めて通知設定した後にinactiveにした際にロック画面が表示されない
          ref.read(isInitialSetNotificationProvider.notifier).state = false;
          return;
        }
        // 上記の全画面広告と端末の通知設定によるinactive時は処理を除外するコードは、
        // 当初「isShowScreenLockProvider」に記載していたが、inactive時にのみ必要な条件分岐のためこちらに記載

        if (ref.read(isShowScreenLockProvider)) {
          await showScreenLock(context, ref);
        }
      }

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
          // パスコードロック画面の表示
          if (ref.read(isShowScreenLockProvider)) {
            await showScreenLock(context, ref);
          }

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

          /// 初回起動時に限り、アラーム設定を促すダイアログを表示する
          ///それに加えて日記記入ダイアログを自動表示する
          ///
          /// ユーザー動作の順番的にSetNotificationDialog→EditDialog→ListPageの順で表示したいため、以下のような記述とした
          if (ref.read(isShowSetNotificationDialogOnLaunchProvider)) {
            await _showSetNotificationDialog(context);
            if (context.mounted) {
              await _showEditDialog(context, null);
            }
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

    final dateController = ref.watch(dateControllerProvider);
    final diaryList = ref.watch(diaryStreamProvider);

    final isPassCodeLocked = ref.watch(isOpenedScreenLockProvider);
    // パスコードロック画面を表示している間は何も表示しない
    // これをしないと一瞬日記画面が表示されてしまうため
    if (isPassCodeLocked) {
      return const SizedBox();
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  _showSetNotificationDialog(context);
                },
                icon: const Icon(Icons.add_alert),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: dateController.previousMonth,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${dateController.selectedMonth.year}年${dateController.selectedMonth.month}月',
                  ),
                  TextButton(
                    onPressed: dateController.nextMonth,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (_) => const SettingPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
            body: SafeArea(
              child: diaryList.when(
                loading: () => const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) {
                  return Scaffold(
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                data: (data) {
                  return Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 8),
                          child: ListView.separated(
                            controller: scrollController,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const Divider(
                                height: 0.5,
                              );
                            },
                            itemCount: dateController.daysInMonth(),
                            itemBuilder: (BuildContext context, int index) {
                              final indexDate = DateTime(
                                dateController.selectedMonth.year,
                                dateController.selectedMonth.month,
                                index + 1,
                              );
                              //TODO firstWhereOrNull使いたい
                              //TODO element.dirayDate = indexDateに修正したい
                              final filteredDiary = data
                                  .where(
                                    (element) =>
                                        element.diaryDate.year ==
                                            indexDate.year &&
                                        element.diaryDate.month ==
                                            indexDate.month &&
                                        element.diaryDate.day == indexDate.day,
                                  )
                                  .toList();
                              final diary = filteredDiary.isNotEmpty
                                  ? filteredDiary[0]
                                  : null;
                              final dayOfWeekStr =
                                  dateController.searchDayOfWeek(indexDate);
                              final dayStrColor =
                                  dateController.choiceDayStrColor(indexDate);
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
                                  ref
                                      .read(selectedDateProvider.notifier)
                                      .state = indexDate;
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
                        ),
                      ),
                      //TODO サブスクプラン加入時には広告非表示に
                      const SizedBox(
                        width: double.infinity,
                        child: ColoredBox(
                          color: Colors.white24,
                          child: AdBanner(
                            size: AdSize.banner,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const ForcedUpdateDialog(),
          const UnderRepairDialog(),
        ],
      ),
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

  Future<void> _showSetNotificationDialog(BuildContext context) async {
    await showDialog<LocalNotificationSettingDialog>(
      context: context,
      builder: (_) {
        return const LocalNotificationSettingDialog(
          trigger: NotificationDialogTrigger.userAction,
        );
      },
    );
  }
}
