import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'auth_repository.dart';

final authServiceProvider = Provider(
  (ref) => AuthService(
    repo: ref.watch(authRepoProvider),
  ),
);

class AuthService {
  AuthService({
    required this.repo,
  });

  final AuthRepository repo;

  Future<void> signInAnonymouslyAndAddUser() async {
    await repo.signInAnonymouslyAndAddUser();
  }

//TODO サインアウト
//   Future<void> signOut() async {
//     await repo.signOut();
//   }

  Future<void> deleteUser() async {
    await repo.deleteUserAccountAndUserData();
  }
}

final userStateProvider = StreamProvider<User?>(
  (ref) {
    //TODO ref.watchに変更？
    final repo = ref.read(authRepoProvider);
    return repo.authStateChanges();
  },
);
