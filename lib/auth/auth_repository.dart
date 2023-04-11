import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthRepository {
  Future<void> signInAnonymously(
    FirebaseAuth auth,
    FirebaseFirestore firestore,
  ) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      try {
        // 匿名認証
        final userCredential = await auth.signInAnonymously();

        // firestoreにUserを登録する
        final user = userCredential.user;
        if (user != null) {
          final uid = user.uid;
          await firestore.collection('users').doc(uid).set(
            {
              'id': uid,
              'createdAt': DateTime.now(),
            },
          );
        }
      } on FirebaseAuthException catch (e) {
        debugPrint(e.toString());
        throw _convertToErrorMessageFromErrorCode(e.code);
      }
    }
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
