import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:limited_characters_diary/firebase_options_dev.dart' as dev;
import 'package:limited_characters_diary/firebase_options_prod.dart' as prod;
import 'package:path_provider/path_provider.dart';

import 'diary/collection/diary.dart';
import 'diary/diary_controller.dart';
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

  //https: //zenn.dev/flutteruniv_dev/articles/20220607-061331-flutter-isar?redirected=1#isar-%E3%82%A4%E3%83%B3%E3%82%B9%E3%82%BF%E3%83%B3%E3%82%B9%E3%82%92%E7%94%9F%E6%88%90%E3%81%99%E3%82%8B
  var path = '';
  if (!kIsWeb) {
    final dir = await getApplicationSupportDirectory();
    path = dir.path;
  }

  final isar = await Isar.open(
    [
      DiarySchema,
    ],
    directory: path,
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (_) => ProviderScope(
        //参考 https://github.com/tomamoi/todo_app/blob/main/lib/main.dart
        overrides: [
          isarProvider.overrideWithValue(isar),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
