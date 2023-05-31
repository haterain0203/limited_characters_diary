import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/constant.dart';
import 'package:limited_characters_diary/feature/setting/terms_of_service/terms_of_service_confirmation_page.dart';
import 'package:sizer/sizer.dart';

import 'feature/admob/ad_providers.dart';
import 'feature/auth/auth_page.dart';

class MyApp extends HookConsumerWidget {
  //TODO check 引数を受けることに問題はないか？（constつけられなくなるが特に気にするほどでもないか？）
  const MyApp({required this.isCompletedFirstLaunch, super.key});

  final bool isCompletedFirstLaunch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        Future(() async {
          // 全画面広告のロード
          await ref.read(adControllerProvider).initInterstitialAdd();
        });
        return null;
      },
      const [],
    );

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          title: 'limited_characters_diary',
          theme: ThemeData(
            primarySwatch: Constant.colorSwatch,
            fontFamily: 'M_PLUS_Rounded_1c',
            appBarTheme: const AppBarTheme(
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
          ),
          home: isCompletedFirstLaunch
              ? const AuthPage()
              : const TermsOfServiceConfirmationPage(),
        );
      },
    );
  }
}
