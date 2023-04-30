import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/constant.dart';
import 'package:limited_characters_diary/web_view_page.dart';
import 'package:settings_ui/settings_ui.dart';

import '../app_info/app_info_providers.dart';
import '../local_notification/local_notification_setting_dialog.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    //なぜかSettingsList内のText（title/tilesともに）にはMyAppに指定したfontFamilyが適用されなかったため、個別で設定
    const textStyle = TextStyle(fontFamily: 'M_PLUS_Rounded_1c');
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: SettingsList(
        platform: DevicePlatform.iOS,
        sections: [
          SettingsSection(
            title: const Text(
              '各種設定',
              style: textStyle,
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.notification_add),
                title: const Text(
                  '通知設定',
                  style: textStyle,
                ),
                onPressed: (BuildContext context) {
                  _showSetNotificationDialog(context);
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text(
              'このアプリについて',
              style: textStyle,
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.mail),
                title: const Text(
                  '問い合わせ',
                  style: textStyle,
                ),
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
              SettingsTile.navigation(
                leading: const Icon(Icons.text_snippet),
                title: const Text(
                  '利用規約',
                  style: textStyle,
                ),
                onPressed: (BuildContext context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (_) => const WebViewPage(
                        title: '利用規約',
                        url: Constant.termsOfServiceUrl,
                      ),
                    ),
                  );
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.text_snippet),
                title: const Text(
                  'プライバシーポリシー',
                  style: textStyle,
                ),
                onPressed: (BuildContext context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (_) => const WebViewPage(
                        title: 'プライバシーポリシー',
                        url: Constant.privacyPolicyUrl,
                      ),
                    ),
                  );
                },
              ),
              SettingsTile(
                leading: const Icon(Icons.info),
                title: const Text(
                  'アプリ名',
                  style: textStyle,
                ),
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
                title: const Text(
                  'アプリバージョン',
                  style: textStyle,
                ),
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
