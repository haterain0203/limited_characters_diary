import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant.dart';
import 'package:limited_characters_diary/web_view_page.dart';
import 'package:settings_ui/settings_ui.dart';

import '../app_info/app_info_providers.dart';
import '../local_notification/local_notification_setting_dialog.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: SettingsList(
        platform: DevicePlatform.iOS,
        sections: [
          SettingsSection(
            title: const Text('各種設定'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.notification_add),
                title: const Text('通知設定'),
                onPressed: (BuildContext context) {
                  _showSetNotificationDialog(context);
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('このアプリについて'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.mail),
                title: const Text('問い合わせ'),
                onPressed: (BuildContext context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (_) => const WebViewPage(
                        title: '問い合わせ',
                        url: Constant.googleFormUrl,
                      ),
                    ),
                  );
                },
              ),
              SettingsTile(
                leading: const Icon(Icons.info),
                title: const Text('アプリ名'),
                trailing: HookConsumer(
                  builder: (context, ref, child) {
                    final appInfo = ref.watch(appInfoProvider);
                    return appInfo.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) {
                        return const Text('エラーが発生しました');
                      },
                      data: (data) => Text(data.appName),
                    );
                  },
                ),
              ),
              SettingsTile(
                leading: const Icon(Icons.info),
                title: const Text('アプリバージョン'),
                trailing: HookConsumer(
                  builder: (context, ref, child) {
                    final appInfo = ref.watch(appInfoProvider);
                    return appInfo.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) {
                        return const Text('エラーが発生しました');
                      },
                      data: (data) => Text(data.version),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
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