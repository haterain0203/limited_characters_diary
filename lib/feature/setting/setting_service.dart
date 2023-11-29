import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/auth/auth_service.dart';

import '../../constant/constant_string.dart';

final settingServiceProvider = Provider.autoDispose(
  (ref) => SettingService(user: ref.watch(userStateProvider).valueOrNull),
);

class SettingService {
  const SettingService({required this.user});
  final User? user;
  Future<String> createContactUsUrl(
      // required PackageInfo appInfo,
      ) async {
    const entryId = 'entry.740690739';
    // final appVersion = '${appInfo.version}(${appInfo.buildNumber})';
    final platform = Platform.operatingSystem;
    final uuid = user?.uid ?? 'null';

    final queryParams = '$entryId=platform:$platform%0Auuid:$uuid';

    final url = '${ConstantString.googleFormBaseUrl}&$queryParams';
    debugPrint('url = $url');

    return url;
  }
}
