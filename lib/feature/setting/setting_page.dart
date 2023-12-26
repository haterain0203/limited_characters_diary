import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/constant_string.dart';
import 'package:limited_characters_diary/constant/enum.dart';
import 'package:limited_characters_diary/feature/auth/auth_controller.dart';
import 'package:limited_characters_diary/feature/in_app_review/in_app_review_controller.dart';
import 'package:limited_characters_diary/feature/local_notification/local_notification_controller.dart';
import 'package:limited_characters_diary/feature/routing/routing_controller.dart';
import 'package:limited_characters_diary/feature/setting/setting_controller.dart';
import 'package:settings_ui/settings_ui.dart';

import '../app_info/app_info_service.dart';
import '../pass_code/pass_code_controller.dart';
import '../pass_code/pass_code_service.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    //なぜかSettingsList内のText（title/tilesともに）にはMyAppに指定したfontFamilyが適用されなかったため、個別で設定
    const textStyle = TextStyle(
      fontFamily: 'M_PLUS_Rounded_1c',
    );
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
          final routingController =
              ref.watch(routingControllerProvider(context));
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
                    leading: const Icon(
                      Icons.account_circle,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'アカウント連携',
                      style: textStyle,
                    ),
                    onPressed: (BuildContext context) {
                      ref
                          .read(routingControllerProvider(context))
                          .goLinkWithSocialAccountPage();
                    },
                  ),
                  SettingsTile.navigation(
                    leading: Icon(
                      Icons.notification_add,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text(
                      'リマインダー設定',
                      style: textStyle,
                    ),
                    onPressed: (BuildContext context) {
                      ref
                          .read(localNotificationControllerProvider)
                          .showSetNotificationDialog(
                            context: context,
                            trigger: NotificationDialogTrigger.userAction,
                          );
                    },
                  ),
                  SettingsTile.switchTile(
                    // 初期値はSharedPreferencesの値が入る
                    initialValue: isPassCodeLock,
                    onToggle: (bool isPassCodeLock) async {
                      await ref
                          .read(passCodeControllerProvider)
                          .onPassCodeToggle(
                            isPassCodeLock: isPassCodeLock,
                            context: context,
                          );
                    },
                    leading: const Icon(
                      Icons.security,
                      color: Colors.green,
                    ),
                    title: const Text(
                      'パスコード設定',
                      style: textStyle,
                    ),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
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
                    onPressed: (_) async {
                      final contactUsUrl = await ref
                          .read(settingControllerProvider)
                          .createContactUsUrl();
                      await routingController.goContactUsOnWebView(
                        url: contactUsUrl,
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    title: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'アプリを評価/レビューする',
                          style: textStyle,
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'レビューいただけると開発の励みになります！',
                          ),
                        ),
                      ],
                    ),
                    onPressed: (_) {
                      ref.read(inAppReviewController).openStore();
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.text_snippet),
                    title: const Text(
                      ConstantString.termsOfServiceStr,
                      style: textStyle,
                    ),
                    onPressed: (_) {
                      routingController.goTermsOfServiceOnWebView();
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.text_snippet),
                    title: const Text(
                      ConstantString.privacyPolicyStr,
                      style: textStyle,
                    ),
                    onPressed: (_) {
                      routingController.goPrivacyPolicyOnWebView();
                    },
                  ),
                  SettingsTile(
                    leading: const Icon(Icons.info),
                    title: const Text(
                      'アプリ名',
                      style: textStyle,
                    ),
                    trailing: Text(appInfo.appName),
                  ),
                  SettingsTile(
                    leading: const Icon(Icons.info),
                    title: const Text(
                      'アプリバージョン',
                      style: textStyle,
                    ),
                    trailing:
                        Text('${appInfo.version}（${appInfo.buildNumber}）'),
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
}
