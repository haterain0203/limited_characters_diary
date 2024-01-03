import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/auth/auth_service.dart';
import 'package:limited_characters_diary/feature/auth/login_page.dart';
import 'package:limited_characters_diary/home_page.dart';

class AuthPage extends HookConsumerWidget {
  const AuthPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    return userState.when(
      data: (user) {
        if (user == null) {
          debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
          debugPrint('user = null のため、ログインページへ遷移します。');
          debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
          return const LoginPage();
        }
        debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
        debugPrint(user.uid);
        debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
        return const HomePage();
      },
      error: (e, s) {
        return Scaffold(
          body: Center(
            // TODO: 問い合わせへの導線追加
            child: Text('エラーが発生しました\n$e'),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
