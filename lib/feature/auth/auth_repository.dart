import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../app_user/app_user.dart';

class AuthRepository {
  AuthRepository({
    required this.auth,
    required this.firestore,
    required this.fcm,
  });

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseMessaging fcm;

  Stream<User?> authStateChanges() => auth.authStateChanges();

  //TODO 匿名認証とユーザー登録の2つの責務が入っているため分割した方が良さそう
  Future<void> signInAnonymouslyAndAddUser() async {
    try {
      // 匿名認証
      final userCredential = await auth.signInAnonymously();

      // firestoreにUserを登録する
      final user = userCredential.user;
      if (user != null) {
        final fcmToken = await fcm.getToken();
        final uid = user.uid;
        final userRef = firestore.collection('users').withConverter<AppUser>(
              fromFirestore: (snapshot, _) =>
                  AppUser.fromJson(snapshot.data()!),
              toFirestore: (user, _) => user.toJson(),
            );
        await userRef.doc(uid).set(
              AppUser(
                uid: uid,
                createdAt: DateTime.now(),
                fcmToken: fcmToken,
              ),
            );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      throw _convertToErrorMessageFromErrorCode(e.code);
    }
  }

  // Future<void> signOut() async {
  //   await auth.signOut();
  // }

  Future<void> deleteUserAccountAndUserData() async {
    final user = auth.currentUser;
    // このメソッドを呼べるのは認証後なので、
    // currentUserがnullになることは基本ないはずだが、念の為nullチェック
    if(user == null) {
      return;
    }
    // Authアカウントの削除
    await user.delete();

  }


  String _convertToErrorMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case 'email-already-exists':
        return '指定されたメールアドレスは既に使用されています。';
      case 'wrong-password':
        return 'パスワードが違います。';
      case 'invalid-email':
        return 'メールアドレスが不正です。';
      case 'user-not-found':
        return '指定されたユーザーは存在しません。';
      case 'user-disabled':
        return '指定されたユーザーは無効です。';
      case 'operation-not-allowed':
        return '指定されたユーザーはこの操作を許可していません。';
      case 'too-many-requests':
        return '指定されたユーザーはこの操作を許可していません。';
      default:
        return '不明なエラーが発生しました。';
    }
  }
}
