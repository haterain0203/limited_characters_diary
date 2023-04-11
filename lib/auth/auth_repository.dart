import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:limited_characters_diary/app_user/app_user.dart';

class AuthRepository {
  AuthRepository({
    required this.auth,
    required this.firestore,
  });

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  Stream<User?> authStateChanges() => auth.authStateChanges();

  Future<void> signInAnonymously() async {
    try {
      // 匿名認証
      final userCredential = await auth.signInAnonymously();

      // firestoreにUserを登録する
      final user = userCredential.user;
      if (user != null) {
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
