import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/analytics/analytics_service.dart';
import 'package:sizer/sizer.dart';

import 'component/dialog_utils.dart';
import 'constant/constant_color.dart';
import 'feature/admob/ad_controller.dart';
import 'feature/auth/auth_page.dart';
import 'feature/setting/terms_of_service/terms_of_service_confirmation_page.dart';

class MyApp extends HookConsumerWidget {
  const MyApp({required this.isCompletedFirstLaunch, super.key});

  final bool isCompletedFirstLaunch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final observer = ref.watch(routeObserverProvider);

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
          navigatorObservers: [observer],
          navigatorKey: ref.watch(navigatorKeyProvider),
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          title: 'limited_characters_diary',
          theme: ThemeData(
            primarySwatch: ConstantColor.colorSwatch,
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
