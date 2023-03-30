import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/component/input_diary_dialog.dart';
import 'package:limited_characters_diary/diary/diary_controller.dart';
import 'package:limited_characters_diary/setting_page.dart';

import 'date/date_controller.dart';
import 'diary/collection/diary.dart';

class ListPage extends HookConsumerWidget {
  const ListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateController = ref.watch(dateControllerProvider);
    final diaryList = ref.watch(diaryFutureProvider);
    return diaryList.when(
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
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(diaryFutureProvider);
                },
                child: const Text('再読み込み'),
              )
            ],
          ),
        );
      },
      data: (data) {
        return Scaffold(
          appBar: AppBar(
            leading: const SizedBox(),
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
          body: ListView.separated(
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                height: 0.5,
              );
            },
            //TODO 固定値
            itemCount: dateController.daysInMonth(),
            itemBuilder: (BuildContext context, int index) {
              final indexDate = DateTime(
                dateController.selectedMonth.year,
                dateController.selectedMonth.month,
                index + 1,
              );
              //TODO firstWhereOrNull使いたい
              final filteredDiary = data
                  .where((element) => element.diaryDate == indexDate)
                  .toList();
              final diary = filteredDiary.isNotEmpty ? filteredDiary[0] : null;
              final dayOfWeekStr = dateController.searchDayOfWeek(indexDate);
              final dayStrColor = dateController.choiceDayStrColor(indexDate);
              final holidayName = dateController.getHolidayName(indexDate);
              return ListTile(
                //本日はハイライト
                tileColor: dateController.isToday(indexDate)
                    ? Colors.amberAccent.shade100
                    : null,
                dense: true,
                leading: Text(
                  '${indexDate.day}（$dayOfWeekStr）',
                  style: TextStyle(color: dayStrColor),
                ),
                title: Text(
                  diary?.content ?? '',
                  // //TODO 日記の内容を表示
                  // holidayName ?? '---',
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
}
