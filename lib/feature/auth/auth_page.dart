import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_lock_or_list_page_switcher.dart';
import 'auth_providers.dart';

class AuthPage extends HookConsumerWidget {
  const AuthPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
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
            try {
              await ref
                  .read(authControllerProvider)
                  .signInAnonymouslyAndAddUser();
            } catch (e) {
              //TODO
              debugPrint(e.toString());
            }
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        debugPrint('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
        debugPrint(data.uid);
        debugPrint('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
        return const PassCodeLockOrListPageSwitcher();
      },
    );
  }
}
