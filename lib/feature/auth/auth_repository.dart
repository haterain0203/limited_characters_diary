import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/constant_string.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../constant/enum.dart';
import '../app_user/app_user.dart';
import '../exception/exception.dart';
import '../fcm/fcm_providers.dart';
import '../firestore/firestore_instance_provider.dart';

final authInstanceProvider = Provider((ref) => FirebaseAuth.instance);

final authRepoProvider = Provider(
  (ref) => AuthRepository(
    auth: ref.watch(authInstanceProvider),
    firestore: ref.watch(firestoreInstanceProvider),
    fcm: ref.watch(fcmInstanceProvider),
    userRef: ref.watch(userRefProvider),
  ),
);

final userRefProvider = Provider((ref) {
  final firestore = ref.watch(firestoreInstanceProvider);
  final userRef = firestore.collection('users').withConverter<AppUser>(
        fromFirestore: (snapshot, _) => AppUser.fromJson(snapshot.data()!),
        toFirestore: (user, _) => user.toJson(),
      );
  return userRef;
});

class AuthRepository {
  AuthRepository({
    required this.auth,
    required this.firestore,
    required this.fcm,
    required this.userRef,
  });

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseMessaging fcm;
  final CollectionReference<AppUser> userRef;

  Stream<User?> authStateChanges() => auth.authStateChanges();

  Future<UserCredential> signInAnonymously() async {
    // 匿名認証
    return auth.signInAnonymously();
  }

  /// [FirebaseAuth] に Google でサインインする。
  ///
  /// https://firebase.flutter.dev/docs/auth/social/#google に従っているが、
  /// [AuthCredential] を取得するまでの処理は、
  /// [_linkWithCredential] でも使用するため、別メソッドして定義している
  Future<UserCredential> signInWithGoogle() async {
    final credential = await _getGoogleAuthCredential();

    final userCredential = await auth.signInWithCredential(credential);
    return userCredential;
  }

  /// [FirebaseAuth] に Apple でサインインする。
  ///
  /// https://firebase.flutter.dev/docs/auth/social/#apple に従っているが、
  /// [AuthCredential] を取得するまでの処理は、
  /// [_linkWithCredential] でも使用するため、別メソッドして定義している
  Future<UserCredential> signInWithApple() async {
    final oauthCredential = await _getAppleAuthCredential();

    final userCredential = await auth.signInWithCredential(oauthCredential);
    return userCredential;
  }

  Future<void> addUser(User user) async {
    // firestoreにUserを登録する
    final fcmToken = await fcm.getToken();
    final uid = user.uid;
    await userRef.doc(uid).set(
          AppUser(
            uid: uid,
            createdAt: DateTime.now(),
            fcmToken: fcmToken,
          ),
        );
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  /// ユーザーアカウントと関連データを削除する。
  ///
  /// この関数は、認証されたユーザーのFirebase Authアカウントと、Firestoreに保存されている
  /// ユーザー関連データを削除します。Firestoreのバッチ処理を使用してサブコレクションのデータも削除します。
  /// セキュリティのため、特定の条件下ではユーザーに再認証が求められます。
  Future<void> deleteUserAccountAndUserData() async {
    final user = auth.currentUser;
    // currentUserがnullの場合、処理を中断する。
    // このメソッドを呼べるのは認証後なので、
    // currentUserがnullになることは基本ないはずだが。
    if (user == null) {
      return;
    }

    // 現在の認証プロバイダを確認する。
    final signedInProviderId = _getSignedInProviderId(user);
    // ソーシャル連携（Google or Apple）済みの場合、セキュリティの観点から再ログインを促す。
    // ログインから一定時間が経過している場合、以下のエラーが発生することへの対応。
    // [firebase_auth/requires-recent-login]
    // This operation is sensitive and requires recent authentication.
    // Log in again before retrying this request.
    if (signedInProviderId == ConstantString.googleProviderId) {
      final credential = await _getGoogleAuthCredential();
      await user.reauthenticateWithCredential(credential);
    } else if (signedInProviderId == ConstantString.appleProviderId) {
      final credential = await _getAppleAuthCredential();
      await user.reauthenticateWithCredential(credential);
    }

    final uid = user.uid;
    final userRef = firestore.collection('users').doc(uid);

    // Firestoreのサブコレクション「diaryList」を削除。
    // Cloud Functionsへの移行を検討中（TODO）。
    final diaryListSnapshot = await userRef.collection('diaryList').get();

    // Firestoreのバッチ処理を初期化。
    var batch = firestore.batch();

    var counter = 0;
    if (diaryListSnapshot.size > 0) {
      for (final doc in diaryListSnapshot.docs) {
        batch.delete(doc.reference);
        counter++;

        // Firestoreのバッチ処理には500の操作の制限があるため、diaryListのドキュメントの数が500を超える場合を考慮。
        if (counter == 500) {
          await batch.commit();
          batch = firestore.batch();
          counter = 0;
        }
      }
    }
    // Commit the batch
    await batch.commit();

    // Firestore上のユーザー情報を削除。
    await userRef.delete();

    // Firebase Authアカウントを削除。
    // データ削除よりも前にアカウント削除してしまうと、
    // セキュリティルールの「isUserAuthenticated(userId)」で引っかかりエラーが発生する。
    await user.delete();

    // サインアウト処理。
    // ソーシャル認証済みのアカウントの場合、これをしないとエラーになる。
    // また、`user.delete` 以前に実行すると以下エラーが発生するため、最後に記述するもの。
    // [firebase_auth/no-current-user] No user currently signed in.
    await signOut();
  }

  /// 指定されたソーシャル認証情報をアカウントにリンクする。
  ///
  /// 指定された [SignInMethod] のソーシャル認証情報をアカウントにリンクする。
  Future<void> linkUserSocialLogin({
    required SignInMethod signInMethod,
    // required String userId,
  }) async {
    await _linkWithCredential(signInMethod: signInMethod);
    // TODO: Userドキュメントに連携情報を追加する
    // await _updateUserSocialLoginSignInMethodStatus(
    //   signInMethod: signInMethod,
    //   userId: userId,
    //   value: true,
    // );
  }

  /// ログイン時に取得される [AuthCredential] を元に、ユーザーアカウントにソーシャル認証情報をリンクする
  Future<void> _linkWithCredential({required SignInMethod signInMethod}) async {
    final credential = switch (signInMethod) {
      SignInMethod.google => await _getGoogleAuthCredential(),
      SignInMethod.apple => await _getAppleAuthCredential(),
    };
    await auth.currentUser?.linkWithCredential(credential);
  }

  /// Google認証から [AuthCredential] を取得する
  ///
  /// [GoogleSignIn] ライブラリを使用してユーザーにGoogleでのログインを求め、
  /// 成功した場合はその認証情報からFirebase用の [AuthCredential] オブジェクトを生成して返す
  Future<AuthCredential> _getGoogleAuthCredential() async {
    try {
      final googleUser = await GoogleSignIn().signIn(); // サインインダイアログの表示

      // サインインダイアログでキャンセルが選択された場合には、AppException をスローし、キャンセルされたことを通知する
      if (googleUser == null) {
        throw const AppException(message: 'キャンセルされました。');
      }

      final googleAuth = await googleUser.authentication; // アカウントからトークン生成

      return GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    } on PlatformException catch (e) {
      if (e.code == 'network_error') {
        throw const AppException(message: '接続できませんでした。\nネットワーク状況を確認してください。');
      }
      print(e.code);
      throw const AppException(message: 'Google 認証に失敗しました。');
    }
  }

  /// Apple認証から [AuthCredential] を取得する
  ///
  /// Appleでのログインを求め、
  /// 成功した場合はその認証情報からFirebase用の [AuthCredential] オブジェクトを生成して返す。
  Future<AuthCredential> _getAppleAuthCredential() async {
    try {
      final rawNonce = generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      return OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      // サインインダイアログでキャンセルが選択された場合には、AppException をスローし、キャンセルされたことを通知する
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AppException(message: 'キャンセルされました');
      }
      throw const AppException(message: 'Apple 認証に失敗しました。');
    }
  }

  /// 文字列から SHA-256 ハッシュを作成する。
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 指定されたソーシャル認証情報のリンクを解除する
  ///
  /// 指定された [SignInMethod] のソーシャル認証情報のリンクを解除する。
  Future<void> unLinkUserSocialLogin({
    required SignInMethod signInMethod,
  }) async {
    await _unlinkWithProviderId(signInMethod: signInMethod);
  }

  /// ログインユーザーが持つ `providerId` を元に、指定された [SignInMethod] のリンクを解除する
  Future<void> _unlinkWithProviderId({
    required SignInMethod signInMethod,
  }) async {
    final user = auth.currentUser;

    if (user == null) {
      return;
    }

    final providerIdToUnlink = switch (signInMethod) {
      SignInMethod.google => ConstantString.googleProviderId,
      SignInMethod.apple => ConstantString.appleProviderId,
    };

    final signedInProviderId = _getSignedInProviderId(user);

    if (signedInProviderId == providerIdToUnlink) {
      await user.unlink(providerIdToUnlink);
    }
  }

  /// 現在サインインしているユーザーの認証プロバイダIDを取得する。
  ///
  /// 現在のFirebase Authユーザーから、利用している認証プロバイダ（Google, Appleなど）のIDを返します。
  ///
  /// [user] 現在サインインしているFirebase Authユーザー。
  ///
  /// 返り値: 認証プロバイダIDを表す文字列。プロバイダデータが存在しない場合は空文字列を返す。
  String _getSignedInProviderId(User user) {
    final providerData = user.providerData;
    // プロバイダデータが存在しない場合（＝匿名認証）は空文字を返す。
    if (providerData.isEmpty) {
      return '';
    }
    // TODO: 複数の認証連携を許可する場合は、要改善。現状では Google or Apple どちらか一つのみ連携できるようになっている。
    return user.providerData.first.providerId;
  }
}
