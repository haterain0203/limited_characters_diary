import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/auth/auth_controller.dart';
import 'package:limited_characters_diary/feature/auth/widget/auth_button.dart';
import 'package:limited_characters_diary/feature/routing/routing_controller.dart';
import 'package:sizer/sizer.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 100),
                    child: SizedBox(
                      height: 20.h,
                      width: 20.h,
                      //TODO flutter_genの導入
                      child: Image.asset('assets/images/icon.png'),
                    ),
                  ),
                  const AuthButton.googleLogin(),
                  const SizedBox(
                    height: 16,
                  ),
                  // iOSの場合のみ、Appleサインインを表示
                  if (Platform.isIOS)
                    const Column(
                      children: [
                        AuthButton.appleLogin(),
                        SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  TextButton(
                    onPressed: () async {
                      await ref
                          .read(authControllerProvider)
                          .signInAnonymouslyAndAddUser();
                    },
                    child: const Text('アカウントなしで利用開始する'),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodySmall,
                      children: <TextSpan>[
                        const TextSpan(text: '本アプリを利用開始することで、'),
                        TextSpan(
                          text: 'プライバシーポリシー',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => ref
                                .read(routingControllerProvider)
                                .goPrivacyPolicyOnWebView(),
                        ),
                        const TextSpan(text: 'と'),
                        TextSpan(
                          text: '利用規約',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => ref
                                .read(routingControllerProvider)
                                .goTermsOfServiceOnWebView(),
                        ),
                        const TextSpan(text: 'に同意したものといたします。'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
