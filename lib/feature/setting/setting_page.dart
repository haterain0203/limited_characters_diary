import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/constant_string.dart';
import 'package:limited_characters_diary/constant/enum.dart';
import 'package:limited_characters_diary/feature/auth/auth_controller.dart';
import 'package:limited_characters_diary/web_view_page.dart';
import 'package:settings_ui/settings_ui.dart';

import '../app_info/app_info_service.dart';
import '../local_notification/local_notification_setting_dialog.dart';
import '../pass_code/pass_code_controller.dart';
import '../pass_code/pass_code_functions.dart';
import '../pass_code/pass_code_service.dart';

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
      body: HookConsumer(
        builder: (context, ref, child) {
          // PassCodeのisPassCodeLockのみ監視する
          final isPassCodeLock = ref.watch(
            passCodeProvider.select((value) => value.isPassCodeEnabled),
          );
          final appInfo = ref.watch(appInfoProvider);
          return SettingsList(
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
                  SettingsTile.switchTile(
                    // 初期値はSharedPreferencesの値が入る
                    initialValue: isPassCodeLock,
                    onToggle: (bool isPassCodeLock) async {
                      // トグルの値がtrue→falseならpassCodeを空文字、isPassCodeをfalse、パスコードロックOFF
                      // false→trueならパスコード登録画面を表示、パスコードを登録、パスコードロックON
                      if (!isPassCodeLock) {
                        await ref.read(passCodeControllerProvider).savePassCode(
                              passCode: '',
                              isPassCodeLock: false,
                            );
                      } else {
                        await showScreenLockCreate(
                          context: context,
                          ref: ref,
                          isPassCodeLock: isPassCodeLock,
                        );
                      }
                    },
                    leading: const Icon(Icons.security),
                    title: const Text(
                      'パスコード設定',
                      style: textStyle,
                    ),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.delete_forever),
                    title: const Text(
                      '退会する（全データ削除）',
                      style: textStyle,
                    ),
                    onPressed: (BuildContext context) {
                      ref
                          .read(authControllerProvider)
                          .showConfirmDeleteAllDataDialog(context);
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
                      ConstantString.contactUsStr,
                      style: textStyle,
                    ),
                    onPressed: (_) {
                      _openWebViewPage(
                        context: context,
                        title: ConstantString.contactUsStr,
                        url: ConstantString.googleFormUrl,
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.text_snippet),
                    title: const Text(
                      ConstantString.termsOfServiceStr,
                      style: textStyle,
                    ),
                    onPressed: (_) {
                      _openWebViewPage(
                        context: context,
                        title: ConstantString.termsOfServiceStr,
                        url: ConstantString.termsOfServiceUrl,
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.text_snippet),
                    title: const Text(
                      ConstantString.privacyPolicyStr,
                      style: textStyle,
                    ),
                    onPressed: (_) {
                      _openWebViewPage(
                        context: context,
                        title: ConstantString.privacyPolicyStr,
                        url: ConstantString.privacyPolicyUrl,
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
                    trailing: appInfo.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) {
                        return const Text('エラーが発生しました');
                      },
                      data: (data) =>
                          Text('${data.version}（${data.buildNumber}）'),
                    ),
                  ),
                  // SettingsTile(
                  //   leading: const Icon(Icons.info),
                  //   title: const Text(
                  //     'サインアウト',
                  //     style: textStyle,
                  //   ),
                  //   trailing: HookConsumer(
                  //     builder: (context, ref, child) {
                  //       return ElevatedButton(
                  //         child: Text('サインアウト'),
                  //         onPressed: () async {
                  //           await ref.read(authControllerProvider).signOut();
                  //         },
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSetNotificationDialog(BuildContext context) {
    showDialog<LocalNotificationSettingDialog>(
      context: context,
      builder: (_) {
        return const LocalNotificationSettingDialog(
          trigger: NotificationDialogTrigger.userAction,
        );
      },
    );
  }

  void _openWebViewPage({
    required BuildContext context,
    required String title,
    required String url,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute<WebViewPage>(
        builder: (_) => WebViewPage(
          title: title,
          url: url,
        ),
      ),
    );
  }
}
