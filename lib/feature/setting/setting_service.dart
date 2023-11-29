import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/app_info/app_info_service.dart';
import 'package:limited_characters_diary/feature/auth/auth_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../constant/constant_string.dart';

final settingServiceProvider = Provider.autoDispose(
  (ref) => SettingService(
    user: ref.watch(userStateProvider).valueOrNull,
    appInfo: ref.watch(appInfoProvider),
  ),
);

class SettingService {
  const SettingService({
    required this.user,
    required this.appInfo,
  });
  final User? user;
  final PackageInfo appInfo;
  Future<String> createContactUsUrl() async {
    const entryIdOfAppVersion = 'entry.740690739';
    const entryIdOfPlatform = 'entry.1589033762';
    const entryIdOfUuid = 'entry.200390007';
    final appVersion =
        '$entryIdOfAppVersion=${appInfo.version}(${appInfo.buildNumber})';
    final platform = '$entryIdOfPlatform=${Platform.operatingSystem}';
    final uuid = '$entryIdOfUuid=${user?.uid ?? 'null'}';

    final queryParams = '$appVersion&$platform&$uuid';

    final url = '${ConstantString.googleFormBaseUrl}&$queryParams';
    debugPrint('url = $url');

    return url;
  }
}
