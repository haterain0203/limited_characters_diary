import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'constant.dart';
import 'feature/auth/auth_providers.dart';
import 'feature/date/date_controller.dart';
import 'feature/diary/diary.dart';
import 'feature/diary/diary_controller.dart';
import 'feature/diary/input_diary_dialog.dart';
import 'feature/local_notification/local_notification_setting_dialog.dart';
import 'feature/setting/setting_page.dart';

class ListPage extends HookConsumerWidget {
  const ListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 「WidgetsBinding.instance.addPostFrameCallback」は、
    // ビルドするたびに呼び出されダイアログが複数重なってしまうため、
    // 既にダイアログが開かれたかを判定するフラグを用意
    final isOpenFirstLaunchDialog = useState(false);
    // StateProviderで初回起動（匿名認証でのアカウント作成）かどうか管理
    final isFirstLaunch = ref.watch(isFirstLaunchProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 初回起動時（匿名認証でのアカウント作成時）に限り、アラーム設定を促すダイアログを表示する
      if (isFirstLaunch == true && isOpenFirstLaunchDialog.value == false) {
        _showSetNotificationDialog(context);
        isOpenFirstLaunchDialog.value = true;
        ref.read(isFirstLaunchProvider.notifier).state = false;
      }
    });

    final dateController = ref.watch(dateControllerProvider);
    final diaryList = ref.watch(diaryStreamProvider);
    return Scaffold(
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
      body: diaryList.when(
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
        data: (data) => ListView.separated(
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
                .where((element) =>
                    element.diaryDate.year == indexDate.year &&
                    element.diaryDate.month == indexDate.month &&
                    element.diaryDate.day == indexDate.day)
                .toList();
            final diary = filteredDiary.isNotEmpty ? filteredDiary[0] : null;
            final dayOfWeekStr = dateController.searchDayOfWeek(indexDate);
            final dayStrColor = dateController.choiceDayStrColor(indexDate);
            return ListTile(
              //本日はハイライト
              tileColor: dateController.isToday(indexDate)
                  ? Constant.accentColor
                  : null,
              dense: true,
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
    AwesomeDialog(
      //TODO ボタンカラー再検討
      context: context,
      dialogType: DialogType.question,
      title: '削除しますか？',
      btnCancelText: 'キャンセル',
      btnCancelOnPress: () {},
      btnOkText: '削除',
      btnOkOnPress: () {
        ref.read(diaryControllerProvider).deleteDiary(diary: diary);
      },
    ).show();
  }

  void _showSetNotificationDialog(BuildContext context) {
    showDialog<LocalNotificationSettingDialog>(
      context: context,
      builder: (_) {
        return const LocalNotificationSettingDialog();
      },
    );
  }
}
