import 'package:limited_characters_diary/auth/auth_repository.dart';

class AuthController {
  AuthController({
    required this.repo,
  });
  final AuthRepository repo;

  Future<void> signInAnonymously() async {
    await repo.signInAnonymously();
  }

//TODO サインアウト
}
