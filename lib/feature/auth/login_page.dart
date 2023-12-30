import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/auth/widget/login_button_apple.dart';
import 'package:limited_characters_diary/feature/auth/widget/login_button_google.dart';
import 'package:sizer/sizer.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20.h,
                width: 20.h,
                //TODO flutter_genの導入
                child: Image.asset('assets/images/icon.png'),
              ),
              const SizedBox(
                height: 120,
              ),
              LoginButtonApple.login(
                onPressed: () {
                  // TODO: ログイン処理
                },
              ),
              const SizedBox(
                height: 16,
              ),
              LoginButtonGoogle.login(
                onPressed: () {
                  // TODO: ログイン処理
                },
              ),
              const SizedBox(
                height: 16,
              ),
              TextButton(
                onPressed: () {},
                child: const Text('ゲストで始める'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
