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
final linkedProvidersProvider = Provider.autoDispose<List<SignInMethod>>((ref) {
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

/// 認証サービスを提供するProvider。
///
/// このProviderは [AuthService] インスタンスを提供します。
/// [authRepoProvider]を使用して、認証リポジトリへの参照を取得し、それを [AuthService] に渡します。
final authServiceProvider = Provider(
  (ref) => AuthService(
    repo: ref.watch(authRepoProvider),
  ),
);

/// 認証サービスクラス。
///
/// このクラスは、Firebase Authenticationを用いた認証処理を担当します。
/// 匿名認証、Google認証、Apple認証、ユーザーの削除、サインアウトなどの機能を提供します。
class AuthService {
  AuthService({
    required this.repo,
  });

  final AuthRepository repo;

  /// 匿名認証を行い、認証されたユーザーをデータベースに追加します。
  Future<void> signInAnonymouslyAndAddUser() async {
    final userCredential = await repo.signInAnonymously();
    final user = _validateUserCredential(userCredential);

    await repo.createUserIfNotExist(user);
  }

  /// Google認証を行い、認証されたユーザーをデータベースに追加します。
  Future<void> signInGoogleAndAddUser() async {
    final userCredential = await repo.signInWithGoogle();
    final user = _validateUserCredential(userCredential);

    await repo.createUserIfNotExist(user);
  }

  /// Apple認証を行い、認証されたユーザーをデータベースに追加します。
  Future<void> signInAppleAndAddUser() async {
    final userCredential = await repo.signInWithApple();
    final user = _validateUserCredential(userCredential);

    await repo.createUserIfNotExist(user);
  }

  /// ユーザー認証の結果を確認し、nullの場合は例外を投げる
  User _validateUserCredential(UserCredential userCredential) {
    final user = userCredential.user;
    if (user == null) {
      throw const AppException(message: '何かしらの理由により認証に失敗しました');
    }
    return user;
  }

  /// 現在のユーザーをサインアウトします。
  Future<void> signOut() async {
    await repo.signOut();
  }

  /// 現在のユーザーアカウントとそのユーザーのデータを削除します。
  Future<void> deleteUser() async {
    await repo.deleteUserAccountAndUserData();
  }

  /// ユーザーを指定されたソーシャルログインとリンクします。
  Future<void> linkUserSocialLogin({required SignInMethod signInMethod}) async {
    await repo.linkUserSocialLogin(signInMethod: signInMethod);
  }

  Future<void> unLinkUserSocialLogin({
    required SignInMethod signInMethod,
  }) async {
    await repo.unLinkUserSocialLogin(signInMethod: signInMethod);
  }
}

/// ユーザーの認証状態を監視するStreamProvider。
///
/// このProviderは、Firebase Authenticationの認証状態の変化を監視します。
/// [authRepoProvider]を使用して、認証リポジトリから認証状態の変化をストリームとして取得します。
///
/// 返り値:
///   - 現在サインインしているユーザー、またはサインインしていない場合は`null`を返します。
final userStateProvider = StreamProvider<User?>(
  (ref) {
    final repo = ref.watch(authRepoProvider);
    return repo.authStateChanges();
  },
);
