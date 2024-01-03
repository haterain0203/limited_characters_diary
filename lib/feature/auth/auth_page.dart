import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/auth/auth_service.dart';
import 'package:limited_characters_diary/feature/auth/login_page.dart';
import 'package:limited_characters_diary/home_page.dart';

/// [AuthPage] は認証状態に基づいて適切な画面を表示するウィジェットです。
///
/// 認証状態は [userStateProvider] を通じて管理され、以下の状態を扱います：
/// - ユーザーがログインしている場合（`user` が非null）: ホームページを表示
/// - ユーザーがログインしていない場合（`user` がnull）: ログインページを表示
/// - エラー発生時: エラーメッセージを表示
/// - それ以外: ローディングを表示
class AuthPage extends HookConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);

    return userState.when(
      // ユーザーのデータに基づいてログインページまたはホームページを表示
      data: (user) {
        if (user == null) {
          debugPrint('user = null のため、ログインページへ遷移します。');
          return const LoginPage();
        }
        debugPrint('ユーザーID: ${user.uid}');
        return const HomePage();
      },
      // エラー発生時にエラーメッセージを表示
      error: (e, s) => Scaffold(
        body: Center(
          // TODO: 問い合わせへの導線追加
          child: Text('エラーが発生しました\n$e'),
        ),
      ),
      // データ読み込み中にインジケータを表示
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
