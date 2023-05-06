import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/admob/ad_banner.dart';
import 'package:limited_characters_diary/feature/admob/ad_providers.dart';
import 'package:limited_characters_diary/feature/diary/sized_list_tile.dart';
import 'package:limited_characters_diary/feature/update_info/forced_update_dialog.dart';
import 'package:limited_characters_diary/feature/update_info/under_repair_dialog.dart';
import 'package:limited_characters_diary/pass_code/pass_code_functions.dart';
import 'package:limited_characters_diary/pass_code/pass_code_providers.dart';

import 'constant/constant.dart';
import 'feature/date/date_controller.dart';
import 'feature/diary/diary.dart';
import 'feature/diary/diary_providers.dart';
import 'feature/diary/input_diary_dialog.dart';
import 'feature/local_notification/local_notification_providers.dart';
import 'feature/local_notification/local_notification_setting_dialog.dart';
import 'feature/setting/setting_page.dart';

class ListPage extends HookConsumerWidget {
  const ListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    useOnAppLifecycleStateChange((previous, current) async {

      /// バックグラウンドになったタイミングで、ScreenLockを呼び出す
      ///
      /// 最初はresumedのタイミングで呼び出そうとしたが、一瞬ListPageが表示されてしまうため、
      /// inactiveのタイミングで呼び出すこととしたもの
      if(current == AppLifecycleState.inactive) {
        // 既にロック画面が開いていたら処理終了
        if(ref.read(isOpenedScreenLockProvider)) {
          return;
        }
        // パスコードロックがOFFなら処理終了
        if(!ref.read(passCodeProvider.select((value) => value.isPassCodeLock))){
          return;
        }
        await showScreenLock(context, ref);
      }

      /// バックグラウンドから復帰時した点の日付とバックグラウンド移行時の日付が異なる場合、値を更新する
      ///
      /// 本日の日付をハイライトさせているが、
      /// アプリをバックグラウンド→翌日にフォアグラウンドに復帰（resume）→アプリは再起動しない場合がある（端末依存）→日付が更新されずにハイライト箇所が正しくならない
      /// 上記の事象へ対応するもの
      // 復帰以外のステータスなら処理終了
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {

      /// 所定条件をクリアしている場合、起動時に日記入力ダイアログを自動表示する
      if(ref.read(isShowEditDialogOnLaunchProvider)) {
        ref.read(isOpenedEditDialogProvider.notifier).state = true;
        await _showEditDialog(context, null);
        return;
      }

      /// 初回起動時に限り、アラーム設定を促すダイアログを表示する
      ///それに加えて日記記入ダイアログを自動表示する
      ///
      /// ユーザー動作の順番的にSetNotificationDialog→EditDialog→ListPageの順で表示したいため、以下のような記述とした
      if (ref.read(isShowSetNotificationDialogOnLaunchProvider)) {
        ref.read(isOpenedSetNotificationDialogOnLaunchProvider.notifier).state = true;
        await _showSetNotificationDialog(context);
        if(context.mounted) {
          await _showEditDialog(context, null);
        }
      }
      //当初は、ForcedUpdateDialog及びUnderRepairDialogもここで表現していたが、
      //これらは、Firestore上のtrue/falseで表示非表示を切り替えたく、Stackで対応することとした
      //ここでも「trueになったら表示」はできるが、「falseになったら非表示」をするには別途変数が必要になりそうで、
      //煩雑になると考え、Stackとしたもの。
    });

    // 全画面広告のロード
    useEffect(
      () {
        ref.read(adControllerProvider).initInterstitialAdd();
        return null;
      },
      const [],
    );

    final dateController = ref.watch(dateControllerProvider);
    final diaryList = ref.watch(diaryStreamProvider);
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
                            separatorBuilder: (BuildContext context, int index) {
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
                              return SizedListTile(
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
                                  ref.read(selectedDateProvider.notifier).state =
                                      indexDate;
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
    final diaryDateStr = '${diary.diaryDate.year}/${diary.diaryDate.month}/${diary.diaryDate.day}';
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
        return const LocalNotificationSettingDialog();
      },
    );
  }
}
