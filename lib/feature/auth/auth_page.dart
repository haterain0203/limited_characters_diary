import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_lock_or_list_page_switcher.dart';

import 'auth_controller.dart';
import 'auth_service.dart';

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
          //TODO check try/catchはController or Provider側に書くべきか？
          try {
            ref.read(authControllerProvider).signInAnonymouslyAndAddUser();
          } catch (e) {
            //TODO
            debugPrint(e.toString());
          }
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
