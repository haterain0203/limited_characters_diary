import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/auth/auth_providers.dart';
import 'package:limited_characters_diary/list_page.dart';

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
          ref.read(authControllerProvider).signInAnonymously();
        }
        return const ListPage();
      },
    );
  }
}
