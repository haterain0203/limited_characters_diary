import 'package:device_preview/device_preview.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/local_notification/local_notification_repository.dart';
import 'package:limited_characters_diary/feature/shared_preferences/shared_preferences_providers.dart';
import 'package:limited_characters_diary/firebase_options_dev.dart' as dev;
import 'package:limited_characters_diary/firebase_options_prod.dart' as prod;
import 'package:shared_preferences/shared_preferences.dart';

import 'feature/local_notification/local_notification_providers.dart';
import 'my_app.dart';

const flavor = String.fromEnvironment('FLAVOR');

Future<void> main() async {
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

  // Firebase App Checkの初期化
  await FirebaseAppCheck.instance.activate(
    // Debug用のトークンを取得 & 登録したDebugトークンを使うためには.debugが必要
    androidProvider:
        kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
    appleProvider:
        kReleaseMode ? AppleProvider.deviceCheck : AppleProvider.debug,
  );

  // Admobの初期化
  await MobileAds.instance.initialize();

  // ローカル通知の初期設定
  final localNotificationRepo = LocalNotificationRepository();
  await localNotificationRepo.init();

  //TODO check
  // SharedPreferencesのインスタンス
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.get(key);

  await Future.wait<void>([
    SharedPreferences.getInstance(),
  ]);

  runApp(
    Phoenix(
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (_) => ProviderScope(
          overrides: [
            localNotificationRepoProvider
                .overrideWithValue(localNotificationRepo),
            sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          ],
          child: const MyApp(),
        ),
      ),
    ),
  );
}
