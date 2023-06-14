import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/update_info/update_info.dart';
import 'package:limited_characters_diary/feature/update_info/update_info_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

//TODO check updateInfoにはControllerがないか違和感ないか？（User側からの操作はないため問題ないと考えるが）
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

  /// 購読したupdateInfoを元に、強制アップデートを促すべきか判定する
  ///
  /// 端末のアプリバージョンとfirestoreで指定されているバージョンを比較し、firebaseの方が新しい場合、
  /// 強制アップデートを促すダイアログを表示するためのboolを返す
  Future<bool> _shouldUpdate(UpdateInfo updateInfo) async {
    // firebaseのrequired_updateがfalseならfalseをリターンして終了
    if (!updateInfo.requiredUpdate) {
      return false;
    }
    final currentVersion = await _getCurrentVersion();
    final requiredVersion =
        await _parseRequiredVersionFromUpdateInfo(updateInfo);
    final requiredUpdate = currentVersion < requiredVersion;
    return requiredUpdate;
  }

  /// Appバージョン情報の取得
  Future<Version> _getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    final currentVersion = Version.parse(info.version);
    return currentVersion;
  }

  /// 購読したupdateInfoから必要なバージョン情報を解析する
  Future<Version> _parseRequiredVersionFromUpdateInfo(
      UpdateInfo updateInfo) async {
    // ユーザー端末がiosかandroidかでupdateInfoのフィールドを変更する
    final os = Platform.isIOS
        ? updateInfo.requiredIosVersion
        : updateInfo.requiredAndroidVersion;
    // updateInfoのバージョン情報をVersionパッケージを使ってparse
    // https://pub.dev/packages/version
    final requiredVersion = Version.parse(os);
    return requiredVersion;
  }
}

/// Firestoreに保存されている「updateInfo」を購読する
final updateInfoProvider = StreamProvider.autoDispose<UpdateInfo>((ref) {
  final repo = ref.watch(updateInfoRepoProvider);
  final updateInfo = repo.subscribedUpdateInfo();
  return updateInfo;
});

/// updateInfoを購読し、強制アップデートを促すべきかどうか判定する
final shouldForcedUpdateProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final updateInfo = ref.watch(updateInfoProvider);
  if (updateInfo.value == null) {
    return false;
  }
  final service = ref.watch(updateInfoServiceProvider);
  return service._shouldUpdate(updateInfo.value!);
});
