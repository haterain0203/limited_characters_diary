import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/enum.dart';
import 'package:limited_characters_diary/feature/auth/widget/auth_button.dart';

import '../auth/auth_service.dart';

class LinkWithSocialAccountPage extends HookConsumerWidget {
  const LinkWithSocialAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkedProviders = ref.watch(linkedProvidersProvider);
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
                'アカウント連携することで、\n'
                '・アプリを誤って削除した場合のデータ復帰\n'
                '・機能変更時のデータ移行\n'
                'が可能になります。',
              ),
            ),
            const SizedBox(height: 32),
            // Google
            _isLinked(
              linkedProviders: linkedProviders,
              signInMethod: SignInMethod.google,
            )
                ? const AuthButton.googleUnLink()
                : const AuthButton.googleLink(),
            // Apple
            if (Platform.isIOS)
              Column(
                children: [
                  const SizedBox(height: 16),
                  _isLinked(
                    linkedProviders: linkedProviders,
                    signInMethod: SignInMethod.apple,
                  )
                      ? const AuthButton.appleUnLink()
                      : const AuthButton.appleLink(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// 指定された [SignInMethod] が、連携済みかどうかを判定する。
  ///
  /// 現在連携されているソーシャル認証のリストである [linkedProviders] に、
  /// 指定された [SignInMethod] が含まれているかどうかを判定する。
  bool _isLinked({
    required List<SignInMethod> linkedProviders,
    required SignInMethod signInMethod,
  }) {
    return linkedProviders.contains(signInMethod);
  }
}
