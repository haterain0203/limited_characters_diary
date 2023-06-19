import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app_user/app_user.dart';
import '../fcm/fcm_providers.dart';
import '../firestore/firestore_instance_provider.dart';

final authInstanceProvider = Provider((ref) => FirebaseAuth.instance);

final authRepoProvider = Provider(
  (ref) => AuthRepository(
      auth: ref.watch(authInstanceProvider),
      firestore: ref.watch(firestoreInstanceProvider),
      fcm: ref.watch(fcmInstanceProvider),
      userRef: ref.watch(userRefProvider)),
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
    //TODO エラーハンドリングはControllerへ
    try {
      // 匿名認証
      return await auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      throw _convertToErrorMessageFromErrorCode(e.code);
    }
  }

  Future<void> addUser(User user) async {
    try {
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
      //TODO Controllerにエラーハンドリングを記述したので、ここでのcatchは不要
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
    }
  }

  // Future<void> signOut() async {
  //   await auth.signOut();
  // }

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

}
