import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/confidential.dart';
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
    final appVersion = '${appInfo.version}(${appInfo.buildNumber})';
    final appVersionParam = '${Confidential.entryIdOfAppVersion}=$appVersion';

    final platform = Platform.operatingSystem;
    final platformParam = '${Confidential.entryIdOfPlatform}=$platform';

    final osVersion = await switch (platform) {
      'ios' => deviceInfo.data['systemVersion'],
      'android' => deviceInfo.data['version']['release'],
      _ => 'unknown',
    };
    final osVersionParam = '${Confidential.entryIdOfOsVersion}=$osVersion';

    final deviceName = await switch (platform) {
      'ios' => deviceInfo.data['name'],
      'android' => deviceInfo.data['model'],
      _ => 'unknown',
    };
    final deviceNameParam = '${Confidential.entryIdOfDeviceName}=$deviceName';

    final uuid = user?.uid ?? 'null';
    final uuidParam = '${Confidential.entryIdOfUuid}=$uuid';

    final queryParams = '$appVersionParam&$platformParam'
        '&$osVersionParam&$deviceNameParam&$uuidParam';

    final url = '${ConstantString.googleFormBaseUrl}&$queryParams';

    return url;
  }
}
