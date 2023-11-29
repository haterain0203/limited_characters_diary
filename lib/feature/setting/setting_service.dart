import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
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
    deviceInfo: ref.watch(deviceInfoProvider),
  ),
);

class SettingService {
  const SettingService({
    required this.user,
    required this.appInfo,
    required this.deviceInfo,
  });
  final User? user;
  final PackageInfo appInfo;
  final BaseDeviceInfo deviceInfo;

  Future<String> createContactUsUrl() async {
    const entryIdOfAppVersion = 'entry.740690739';
    const entryIdOfPlatform = 'entry.1589033762';
    const entryIdOfOsVersion = 'entry.870640106';
    const entryIdOfDeviceName = 'entry.1558888468';
    const entryIdOfUuid = 'entry.200390007';

    final appVersion = '${appInfo.version}(${appInfo.buildNumber})';
    final appVersionParam = '$entryIdOfAppVersion=$appVersion';

    final platform = Platform.operatingSystem;
    final platformParam = '$entryIdOfPlatform=$platform';

    final osVersion = await deviceInfo.data['systemVersion'];
    final osVersionParam = '$entryIdOfOsVersion=$osVersion';

    final deviceName = await deviceInfo.data['name'];
    final deviceNameParam = '$entryIdOfDeviceName=$deviceName';

    final uuid = user?.uid ?? 'null';
    final uuidParam = '$entryIdOfUuid=$uuid';

    final queryParams = '$appVersionParam&$platformParam'
        '&$osVersionParam&$deviceNameParam&$uuidParam';

    final url = '${ConstantString.googleFormBaseUrl}&$queryParams';

    return url;
  }
}
