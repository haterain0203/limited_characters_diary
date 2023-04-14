import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/auth/auth_providers.dart';
import 'package:limited_characters_diary/auth/auth_repository.dart';

class AuthController {
  AuthController({
    required this.repo,
    required this.ref,
  });
  final AuthRepository repo;
  final ProviderRef<dynamic> ref;

  Future<void> signInAnonymously() async {
    await repo.signInAnonymously();
    ref.read(isFirstLaunchProvider.notifier).state = true;
  }

//TODO サインアウト
}
