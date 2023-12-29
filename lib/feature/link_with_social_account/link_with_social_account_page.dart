import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/enum.dart';
import 'package:limited_characters_diary/feature/auth/auth_controller.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LinkWithSocialAccountPage extends HookConsumerWidget {
  const LinkWithSocialAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント連携'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'アカウント登録することで、\n'
                '・アプリを誤って削除した場合のデータ復帰\n'
                '・機能変更時のデータ移行\n'
                'が可能になります。',
              ),
            ),
            const SizedBox(height: 32),
            // Appleで続けるボタン
            if (Platform.isIOS)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: SignInButton(
                      Buttons.appleDark,
                      text: 'Appleで続ける',
                      shape: const StadiumBorder(),
                      onPressed: () {
                        // TODO: Apple連携
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Googleで続けるボタン
            SizedBox(
              width: double.infinity,
              height: 45,
              child: SignInButton(
                Buttons.google,
                text: 'Googleで続ける',
                shape: const StadiumBorder(),
                onPressed: () {
                  // TODO: Google連携
                  ref
                      .read(authControllerProvider)
                      .linkUserSocialLogin(signInMethod: SignInMethod.google);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
