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
    final uid = user.uid;
    final userRef = firestore.collection('users').doc(uid);

    //TODO サブコレクションをすべて削除する処理は、CloudFunctionsに変更すべき？
    // サブコレクションのdiaryListをすべて削除
    final diaryListSnapshot = await userRef.collection('diaryList').get();

    // Initialize a new WriteBatch
    var batch = firestore.batch();

    var counter = 0;
    if(diaryListSnapshot.size > 0) {
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

    // サインアウト処理
    // セッションが残ってしまう可能性を考慮
    await auth.signOut();
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
