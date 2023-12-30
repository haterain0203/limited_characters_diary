import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constant/enum.dart';
import '../exception/exception.dart';
import 'auth_repository.dart';

/// 現在サインインしているユーザーが連携している認証プロバイダを取得するProvider。
///
/// このProviderは、現在Firebase Authenticationにサインインしているユーザーの認証プロバイダ情報を返します。
/// [authInstanceProvider] を監視し、現在のユーザー情報を取得しています。
///
/// 返り値:
///   - ユーザーがサインインしていない場合は空のリストを返します。
///   - ユーザーがサインインしている場合、サインインに使用された認証プロバイダのリスト（`List<SignInMethod>`）を返します。
///   - サポートされていない認証プロバイダが検出された場合は、`AppException`をスローします。
///
/// 使用されている認証プロバイダは、`SignInMethod` enumによって表されます。現在サポートされているのは`google`と`apple`です。
/// ユーザーがGoogleまたはAppleでサインインしている場合、それぞれ`SignInMethod.google`、`SignInMethod.apple`がリストに追加されます。
///
/// 例外:
///   - 未知のサインイン方法（`providerId`がサポートされていない値）が検出された場合、`AppException`がスローされます。
final linkedProvidersProvider = Provider<List<SignInMethod>>((ref) {
  final auth = ref.watch(authInstanceProvider);
  final user = auth.currentUser;
  if (user == null) {
    return [];
  }

  final linkedProviders = <SignInMethod>[];
  for (final providerInfo in user.providerData) {
    switch (providerInfo.providerId) {
      case 'google.com':
        linkedProviders.add(SignInMethod.google);
        break;
      case 'apple.com':
        linkedProviders.add(SignInMethod.apple);
        break;
      default:
        throw AppException(message: '未知のサインイン方法: ${providerInfo.providerId}');
    }
  }

  return linkedProviders;
});

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
    final userCredential = await repo.signInAnonymously();
    final user = userCredential.user;
    if (user != null) {
      await repo.addUser(user);
    }
  }

//TODO サインアウト
  Future<void> signOut() async {
    await repo.signOut();
  }

  Future<void> deleteUser() async {
    await repo.deleteUserAccountAndUserData();
  }

  Future<void> linkUserSocialLogin({required SignInMethod signInMethod}) async {
    await repo.linkUserSocialLogin(signInMethod: signInMethod);
  }
}

final userStateProvider = StreamProvider<User?>(
  (ref) {
    final repo = ref.watch(authRepoProvider);
    return repo.authStateChanges();
  },
);
