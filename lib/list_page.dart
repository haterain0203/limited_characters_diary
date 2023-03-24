import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/setting_page.dart';

import 'date/date_controller.dart';

class ListPage extends HookConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateController = ref.watch(dateControllerProvider);
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
              '${dateController.selectedDate.year}年${dateController.selectedDate.month}月',
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
          final day = index + 1;
          final dayOfWeekStr = dateController.searchDayOfWeek(day);
          final dayStrColor = dateController.choiceDayStrColor(day);
          final holidayName = dateController.getHolidayName(day);
          return ListTile(
            //本日はハイライト
            tileColor: dateController.isToday(day)
                ? Colors.amberAccent.shade100
                : null,
            dense: true,
            leading: Text(
              '$day（$dayOfWeekStr）',
              style: TextStyle(color: dayStrColor),
            ),
            title: Text(
              //TODO 日記の内容を表示
              holidayName ?? '---',
            ),
            onTap: () {
              _showEditDialog(context);
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog<AlertDialog>(
      context: context,
      builder: (_) {
        return AlertDialog(
          content: TextField(
            keyboardType: TextInputType.text,
            maxLength: 16,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                //TODO add or edit処理
              },
              child: Text('保存'),
            ),
          ],
        );
      },
    );
  }
}
