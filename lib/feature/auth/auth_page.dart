import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/list_page.dart';
import 'package:limited_characters_diary/pass_code/pass_code_providers.dart';

import '../../pass_code/pass_code_page.dart';
import 'auth_providers.dart';

class AuthPage extends HookConsumerWidget {
  const AuthPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    final isPassCodeEnabled = ref.watch(passCodeProvider.select((value) => value.isPassCodeEnabled));
    return userState.when(
      error: (e, s) => Scaffold(
        body: Center(
          child: Text(
            e.toString(),
          ),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      data: (data) {
        if (data == null) {
          // signInAnonymously()とisFirstLaunchProviderをtrueにする処理を並べて書くためにFutureでラップし
          // Futureでラップしてawaitを付与せずに実行するとエラーになる
          Future(() async {
            await ref.read(authControllerProvider).signInAnonymously();
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return isPassCodeEnabled ? const PassCodePage() : const ListPage();
      },
    );
  }
}
