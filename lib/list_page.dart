import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/setting_page.dart';

import 'date_controller.dart';

class ListPage extends HookConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final dayOfWeek = ref.watch(dayOfWeekProvider);
    final daysInMonth = ref.watch(daysInMonthProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                //TODO 月を変更する処理
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
            Text('${today.year}年${today.month}月'),
            TextButton(
              onPressed: () {
                //TODO 月を変更する処理
              },
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
        itemCount: daysInMonth,
        itemBuilder: (BuildContext context, int index) {
          final day = index + 1;
          return ListTile(
            dense: true,
            //TODO 本日はハイライト
            leading: Text(
              //TODO 日付と曜日が入ります
              //TODO 土日祝日は色を変える
              day.toString(),
            ),
            title: const Text(
              //TODO 日記の内容を表示
              '日記が入ります',
            ),
          );
        },
      ),
    );
  }
}
