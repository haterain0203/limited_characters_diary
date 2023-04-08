import 'package:flutter/material.dart';
import 'package:limited_characters_diary/local_notification/local_notification_setting_page.dart';
import 'package:settings_ui/settings_ui.dart';

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
                  //TODO GoogleFormへ
                },
              ),
              SettingsTile(
                leading: const Icon(Icons.info),
                title: const Text('アプリバージョン'),
                //TODO アプリバージョン表示
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSetNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return LocalNotificationSettingPage();
      },
    );
  }
}
