import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/enum.dart';
import 'package:limited_characters_diary/feature/admob/ad_banner.dart';
import 'package:limited_characters_diary/feature/diary/diary_list.dart';
import 'package:limited_characters_diary/feature/update_info/forced_update_dialog.dart';
import 'package:limited_characters_diary/feature/update_info/under_repair_dialog.dart';

import 'feature/date/date_controller.dart';
import 'feature/local_notification/local_notification_setting_dialog.dart';
import 'feature/setting/setting_page.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDateTime = ref.watch(selectedDateTimeProvider);

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
                    onPressed: () {
                      // 前の月へ
                      ref.read(selectedDateTimeProvider.notifier).update(
                            (state) => DateTime(state.year, state.month - 1),
                          );
                    },
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
                    '${selectedDateTime.year}年${selectedDateTime.month}月',
                  ),
                  TextButton(
                    onPressed: () {
                      // 次の月へ
                      ref.read(selectedDateTimeProvider.notifier).update(
                            (state) => DateTime(state.year, state.month + 1),
                          );
                    },
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
              child: Column(
                children: const [
                  Expanded(
                    child: DiaryList(),
                  ),
                  //TODO サブスクプラン加入時には広告非表示に
                  SizedBox(
                    width: double.infinity,
                    child: ColoredBox(
                      color: Colors.white24,
                      child: AdBanner(
                        size: AdSize.banner,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const ForcedUpdateDialog(),
          const UnderRepairDialog(),
        ],
      ),
    );
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
