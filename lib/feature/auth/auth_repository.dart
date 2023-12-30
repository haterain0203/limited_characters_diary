import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

  Future<void> deleteUserAccountAndUserData() async {
    final user = auth.currentUser;
    // このメソッドを呼べるのは認証後なので、
    // currentUserがnullになることは基本ないはずだが、念の為nullチェック
    if (user == null) {
      return;
    }

    final uid = user.uid;
    final userRef = firestore.collection('users').doc(uid);

    //TODO サブコレクションをすべて削除する処理は、CloudFunctionsに変更すべき？
    // サブコレクションのdiaryListをすべて削除
    final diaryListSnapshot = await userRef.collection('diaryList').get();

    // Initialize a new WriteBatch
    var batch = firestore.batch();

    var counter = 0;
    if (diaryListSnapshot.size > 0) {
      for (final doc in diaryListSnapshot.docs) {
        batch.delete(doc.reference);
        counter++;

        // Firestoreのバッチ処理には500の操作の制限があるため、diaryListのドキュメントの数が500を超える場合を考慮
        if (counter == 500) {
          await batch.commit();
          batch = firestore.batch();
          counter = 0;
        }
      }
    }
    // Commit the batch
    await batch.commit();

    // users情報の削除
    await userRef.delete();

    // Authアカウントの削除
    // データ削除よりも前にアカウント削除してしまうと、
    // セキュリティルールの「isUserAuthenticated(userId)」で引っかかりエラーが発生する
    // そのため、アカウント削除は最後に実行する
    await user.delete();
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
}
