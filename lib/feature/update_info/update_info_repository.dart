import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:limited_characters_diary/feature/update_info/update_info.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

class UpdateInfoRepository {
  UpdateInfoRepository({required this.updateInfoRef});
  final DocumentReference<UpdateInfo> updateInfoRef;

  Stream<UpdateInfo> subscribedUpdateInfo() {
    final snapshots = updateInfoRef.snapshots();
    final updateInfo = snapshots.map((snapshot) {
      return snapshot.data()!;
    });
    return updateInfo;
  }

  //TODO ここも向きが逆転しているかも
  // 端末のアプリバージョンとfirebaseのバージョンを比較し、firebaseの方が新しい場合、
  // 強制アップデートを促すダイアログを表示するためのboolを返す
  Future<bool> requiredUpdate(UpdateInfo updateInfo) async {
    // firebaseのrequired_updateがfalseならfalseをリターンして終了
    if (!updateInfo.requiredUpdate) {
      return false;
    }
    // firebaseのrequired_updateがtrueなら強制アップデート判定に進む
    final currentVersion = await getCurrentVersion();
    final requiredVersion = await getRequiredVersion(updateInfo);
    final requiredUpdate = currentVersion < requiredVersion;
    return requiredUpdate;
  }

  // Appのバージョン情報の取得
  Future<Version> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    final currentVersion = Version.parse(info.version);
    return currentVersion;
  }

  // firebaseのバージョン情報を取得
  Future<Version> getRequiredVersion(UpdateInfo updateInfo) async {
    // iosかandroidかでfirebaseから取得するフィールド名を変更する
    final os = Platform.isIOS
        ? updateInfo.requiredIosVersion
        : updateInfo.requiredAndroidVersion;
    //Firestoreからアップデートしたいバージョンを取得
    final newVersion = Version.parse(os);
    return newVersion;
  }
}
