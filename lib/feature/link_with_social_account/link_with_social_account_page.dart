import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/enum.dart';
import 'package:limited_characters_diary/feature/auth/auth_controller.dart';
import 'package:limited_characters_diary/feature/auth/widget/login_button_google.dart';

import '../auth/auth_service.dart';
import '../auth/widget/login_button_apple.dart';

class LinkWithSocialAccountPage extends HookConsumerWidget {
  const LinkWithSocialAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkedProviders = ref.watch(linkedProvidersProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント連携'),
      ),
      body: linkedProviders.isEmpty
          ? const _NotLinked()
          : _Linked(
              signedInMethodList: linkedProviders,
            ),
    );
  }
}

class _NotLinked extends HookConsumerWidget {
  const _NotLinked();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
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
          // Googleで続けるボタン
          LoginButtonGoogle.link(
            onPressed: () async {
              await ref.read(authControllerProvider).linkUserSocialLogin(
                    signInMethod: SignInMethod.google,
                  );
              ref.invalidate(linkedProvidersProvider);
            },
          ),
          // Appleで続けるボタン
          if (Platform.isIOS)
            Column(
              children: [
                const SizedBox(height: 16),
                LoginButtonApple.link(
                  onPressed: () async {
                    await ref.read(authControllerProvider).linkUserSocialLogin(
                          signInMethod: SignInMethod.apple,
                        );
                    ref.invalidate(linkedProvidersProvider);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Linked extends HookConsumerWidget {
  const _Linked({required this.signedInMethodList});

  final List<SignInMethod> signedInMethodList;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: List.generate(signedInMethodList.length, (index) {
              final signedInMethod = signedInMethodList[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                tileColor: Colors.white,
                title: const Text('ログイン済み'),
                trailing: _getIcon(signedInMethod: signedInMethod),
              );
            }),
          ),
          InkWell(
            onTap: () async {
              await ref.read(authControllerProvider).signOut();
              ref.invalidate(linkedProvidersProvider);
            },
            child: const ListTile(
              leading: FaIcon(FontAwesomeIcons.arrowRightFromBracket),
              title: Text('ログアウト'),
            ),
          ),
        ],
      ),
    );
  }

  FaIcon _getIcon({required SignInMethod signedInMethod}) {
    if (signedInMethod == SignInMethod.apple) {
      return const FaIcon(FontAwesomeIcons.apple);
    }
    return const FaIcon(FontAwesomeIcons.google);
  }
}
