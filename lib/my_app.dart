import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/constant.dart';
import 'package:limited_characters_diary/feature/first_launch/first_launch_providers.dart';
import 'package:limited_characters_diary/feature/setting/terms_of_service/terms_of_service_confirmation_page.dart';
import 'package:sizer/sizer.dart';

import 'feature/auth/auth_page.dart';

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final isCompletedFirstLaunch =
        ref.watch(isCompletedFirstLaunchProvider).value;
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
          home: isCompletedFirstLaunch == null || !isCompletedFirstLaunch
              ? const TermsOfServiceConfirmationPage()
              : const AuthPage(),
        );
      },
    );
  }
}
