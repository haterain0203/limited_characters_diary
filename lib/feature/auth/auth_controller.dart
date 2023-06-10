import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/auth/auth_service.dart';

final authControllerProvider = Provider(
  (ref) => AuthController(
    service: ref.read(authServiceProvider),
  ),
);

class AuthController {
  AuthController({
    required this.service,
  });
  final AuthService service;

  Future<void> signInAnonymouslyAndAddUser() async {
    await service.signInAnonymouslyAndAddUser();
  }

//TODO サインアウト
//   Future<void> signOut() async {
//     await repo.signOut();
//   }

  Future<void> deleteUser() async {
    await service.deleteUser();
  }
}

/// ユーザーデータ削除時には日記入力ダイアログを表示しないように制御するため
final isUserDeletedProvider = StateProvider((ref) => false);

final authInstanceProvider = Provider((ref) => FirebaseAuth.instance);
