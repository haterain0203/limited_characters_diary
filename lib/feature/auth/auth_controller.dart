import 'auth_repository.dart';

class AuthController {
  AuthController({
    required this.repo,
  });
  final AuthRepository repo;

  Future<void> signInAnonymouslyAndAddUser() async {
    await repo.signInAnonymouslyAndAddUser();
  }

//TODO サインアウト
}
