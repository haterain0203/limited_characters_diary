import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/app_info/app_info_service.dart';
import 'package:limited_characters_diary/feature/shared_preferences/shared_preferences_instance_provider.dart';
import 'package:limited_characters_diary/firebase_options_dev.dart' as dev;
import 'package:limited_characters_diary/firebase_options_prod.dart' as prod;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'feature/local_notification/local_notification_repository.dart';
import 'feature/local_notification/local_notification_service.dart';
import 'my_app.dart';

const flavor = String.fromEnvironment('flavor');

Future<void> main() async {
  /// クラッシュハンドラ
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      //向き指定
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp, //縦固定
      ]);

      debugPrint('flavor = $flavor');

      // Flavor に応じた FirebaseOptions を準備する
      final firebaseOptions = flavor == 'prod'
          ? prod.DefaultFirebaseOptions.currentPlatform
          : dev.DefaultFirebaseOptions.currentPlatform;

      // Firebase の初期化
      await Firebase.initializeApp(
        options: firebaseOptions,
      );

      /// クラッシュハンドラ(Flutterフレームワーク内でスローされたすべてのエラー)
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      // Firebase App Checkの初期化
      await FirebaseAppCheck.instance.activate(
        // Debug用のトークンを取得 & 登録したDebugトークンを使うためには.debugが必要
        androidProvider: kReleaseMode
            ? AndroidProvider.playIntegrity
            : AndroidProvider.debug,
        appleProvider:
            kReleaseMode ? AppleProvider.deviceCheck : AppleProvider.debug,
      );

      // Admobの初期化
      await MobileAds.instance.initialize();

      // SharedPreferencesのインスタンス
      final prefs = await SharedPreferences.getInstance();

      // ローカル通知の初期設定
      final localNotificationRepo = LocalNotificationRepository(prefs: prefs);
      final localNotificationService = LocalNotificationService(
        repo: localNotificationRepo,
      );
      await localNotificationService.init();

      final appInfo = await PackageInfo.fromPlatform();
      final deviceInfo = await DeviceInfoPlugin().deviceInfo;

      runApp(
        Phoenix(
          child: DevicePreview(
            enabled: !kReleaseMode,
            builder: (_) => ProviderScope(
              overrides: [
                localNotificationServiceProvider
                    .overrideWithValue(localNotificationService),
                localNotificationRepoProvider
                    .overrideWithValue(localNotificationRepo),
                sharedPreferencesInstanceProvider.overrideWithValue(prefs),
                appInfoProvider.overrideWithValue(appInfo),
                deviceInfoProvider.overrideWithValue(deviceInfo),
              ],
              child: const MyApp(),
            ),
          ),
        ),
      );
    },

    /// クラッシュハンドラ(Flutterフレームワーク内でキャッチされないエラー)
    (error, stack) =>
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
  );
}
