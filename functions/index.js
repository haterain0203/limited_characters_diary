/**
 * Firebase Functions Shellを使用したローカルテスト手順
 *
 * 1. Firebase CLIのセットアップ
 *    - Firebase CLIをインストールしていない場合は、まずインストールが必要です。
 *
 * 2. プロジェクトの選択
 *    - 作業するFirebaseプロジェクトを選択します。以下のコマンドを使用して、プロジェクトを指定します。
 *      ```
 *      firebase use limited-characters-diary-prod
 *      ```
 *      ここで 'limited-characters-diary-prod' は使用するプロジェクトのIDに置き換えてください。
 *
 * 3. プロジェクトディレクトリに移動
 *    - Firebaseプロジェクトのルートディレクトリに移動します。ここにはfunctionsディレクトリが含まれている必要があります。
 *    - このプロジェクトの場合、`limited_characters_diary`
 *
 * 4. Firebase Functions Shellの起動
 *    - ターミナルで次のコマンドを実行し、Firebase Functions Shellを起動します。
 *      ```
 *      firebase functions:shell
 *      ```
 *
 * 5. backupUserData関数のテスト
 *    - Shellで以下のコマンドを実行して、backupUserData関数をテストします。
 *      ```
 *      backupUserData({ userId: 'ユーザーID' })
 *      ```
 *      ここで 'ユーザーID' はテストするユーザーの実際のIDに置き換えてください。
 *
 * 6. restoreUserDiaries関数のテスト
 *    - Shellで以下のコマンドを実行して、restoreUserDiaries関数をテストします。
 *      ```
 *      restoreUserDiaries({ oldUserId: '古いユーザーID', newUserId: '新しいユーザーID' })
 *      ```
 *      ここで '古いユーザーID' と '新しいユーザーID' はテストするユーザーの実際のIDに置き換えてください。
 *
 * 7. 結果の確認
 *    - 関数が正常に実行されると、その結果がShellに表示されます。
 *
 * 関数の説明：
 * - restoreCompleteUserData:
 *   - 特定のユーザーの全データをバックアップから復元します。
 *   - ユーザーのプロファイル情報、設定など、ユーザーに関連するすべての情報を含む可能性があります。
 * - restoreUserDiaries:
 *   - 特定のユーザーの日記リストのみを別のユーザーIDにバックアップから復元します。
 *   - この関数は、ユーザーの日記エントリーのみを移動またはコピーし、他のユーザーデータは影響を受けません。
 *
 * 注意：これらの手順はローカル環境でのテストにのみ適用され、プロダクション環境での適用は推奨されません。
 */


const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.backupUserData = functions.https.onCall(async (data, context) => {
  const userId = data.userId;

  try {
    // ユーザードキュメントを取得
    const userDocRef = admin.firestore().collection("users").doc(userId);
    const userDoc = await userDocRef.get();
    if (!userDoc.exists) {
      throw new Error("User not found");
    }
    const userData = userDoc.data();

    // ユーザーデータをバックアップ
    const backupDocRef = admin.firestore().collection("backups").doc(userId);
    await backupDocRef.set(userData);

    // サブコレクションの日記リストを取得
    const diaryListRef = userDocRef.collection("diaryList");
    const diaryListSnapshot = await diaryListRef.get();
    const diaryListBackupRef = backupDocRef.collection("diaryList");

    // 各日記をバックアップサブコレクションに保存
    const diaryListBackupPromises = diaryListSnapshot.docs.map((diaryDoc) => {
      const diaryData = diaryDoc.data();
      return diaryListBackupRef.doc(diaryDoc.id).set(diaryData);
    });

    // 全てのプロミスを実行
    await Promise.all(diaryListBackupPromises);

    return {message: "Backup successful"};
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message);
  }
});

// 特定のユーザーデータのすべてを復元する関数（userドキュメントおよびdiaryListSubCollection全て）
exports.restoreCompleteUserData = functions.https.onCall((data, context) => {
  // ユーザーIDを取得
  const userId = data.userId;

  // バックアップからデータを取得
  return admin.firestore().collection("backups").doc(userId).get()
      .then((doc) => {
        if (!doc.exists) {
          throw new Error("Backup not found");
        }

        // ユーザーデータを復元
        const userData = doc.data();
        return admin.firestore().collection("users").doc(userId).set(userData);
      })
      .then(() => {
        return {message: "Restore successful"};
      })
      .catch((error) => {
        throw new functions.https.HttpsError("internal", error.message);
      });
});

// 特定のdiaryListサブコレクションのみを復元する関数
exports.restoreUserDiaries = functions.https.onCall(async (data, context) => {
  const oldUserId = data.oldUserId;
  const newUserId = data.newUserId;

  try {
    // 旧UUIDのバックアップデータからdiaryListサブコレクションを取得
    const oldDiaryListRef = admin.firestore().collection("backups")
        .doc(oldUserId).collection("diaryList");
    const oldDiaryListSnapshot = await oldDiaryListRef.get();

    if (oldDiaryListSnapshot.empty) {
      throw new Error("No diaries to restore");
    }

    // 新UUIDのdiaryListサブコレクションを取得
    const newDiaryListRef = admin.firestore().collection("users")
        .doc(newUserId).collection("diaryList");

    // 各日記を新UUIDのdiaryListサブコレクションに保存
    const diaryListRestorePromises = oldDiaryListSnapshot
        .docs.map((diaryDoc) => {
          return newDiaryListRef.doc(diaryDoc.id).set(diaryDoc.data());
        });

    // すべてのプロミスを実行
    await Promise.all(diaryListRestorePromises);

    return {message: "Diaries restored successfully to the new user"};
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message);
  }
});


