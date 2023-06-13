import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/update_info/update_info.dart';
import 'package:limited_characters_diary/feature/update_info/update_info_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

import '../firestore/firestore_instance_provider.dart';

final updateInfoServiceProvider = Provider(
  (ref) => UpdateInfoService(
    repo: ref.watch(updateInfoRepoProvider),
  ),
);

class UpdateInfoService {
  UpdateInfoService({
    required this.repo,
  });

  final UpdateInfoRepository repo;

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

final updateInfoRefProvider = Provider((ref) {
  final firestore = ref.watch(firestoreInstanceProvider);
  final updateInfoRef = firestore
      .collection('update_info')
      .doc('update_info')
      .withConverter<UpdateInfo>(
        fromFirestore: (snapshot, _) => UpdateInfo.fromJson(snapshot.data()!),
        toFirestore: (updateInfo, _) => updateInfo.toJson(),
      );
  return updateInfoRef;
});

final updateInfoProvider = StreamProvider.autoDispose<UpdateInfo>((ref) {
  final repo = ref.watch(updateInfoRepoProvider);
  final updateInfo = repo.subscribedUpdateInfo();
  return updateInfo;
});

final forcedUpdateProvider = FutureProvider.autoDispose<bool>((ref) async {
  //TODO selectを使用すべきか？
  //この書き方だと、FirestoreのUpdateInfoのforcedUpdate以外が更新された場合も処理が走ってしまうのでは？
  final updateInfo = ref.watch(updateInfoProvider);
  if (updateInfo.value == null) {
    return false;
  }
  final service = ref.watch(updateInfoServiceProvider);
  final requiredUpdate = await service.requiredUpdate(updateInfo.value!);
  return requiredUpdate;
});
