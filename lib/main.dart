import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/firebase_options_dev.dart' as dev;
import 'package:limited_characters_diary/firebase_options_prod.dart' as prod;

import 'my_app.dart';

const flavor = String.fromEnvironment('FLAVOR');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Flavor に応じた FirebaseOptions を準備する
  final firebaseOptions = flavor == 'prod'
      ? prod.DefaultFirebaseOptions.currentPlatform
      : dev.DefaultFirebaseOptions.currentPlatform;

  // Firebase の初期化
  await Firebase.initializeApp(
    options: firebaseOptions,
  );

  await MobileAds.instance.initialize();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (_) => const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}
