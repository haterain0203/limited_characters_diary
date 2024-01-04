import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/analytics/analytics_service.dart';
import 'package:limited_characters_diary/feature/auth/auth_page.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_lock_page.dart';
import 'package:limited_characters_diary/scaffold_messenger_controller.dart';
import 'package:sizer/sizer.dart';

import 'constant/constant_color.dart';
import 'feature/admob/ad_controller.dart';
import 'feature/loading/loading.dart';
import 'feature/loading/loading_notifier.dart';
import 'feature/pass_code/pass_code_controller.dart';

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

    // バックグラウンドになったタイミングで、ScreenLock表示管理フラグをtrueにする
    //
    // 最初はresumedのタイミングで呼び出そうとしたが、一瞬ListPageが表示されてしまうため、
    // inactiveのタイミングで呼び出すこととしたもの
    useOnAppLifecycleStateChange((previous, current) async {
      if (current != AppLifecycleState.inactive) {
        return;
      }

      if (!ref
          .read(passCodeControllerProvider)
          .shouldShowPassCodeLockWhenInactive()) {
        return;
      }

      ref.read(shouldShowPassCodeLockPageProvider.notifier).state = true;
    });

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          navigatorObservers: [observer],
          navigatorKey: ref.watch(navigatorKeyProvider),
          scaffoldMessengerKey: ref.watch(scaffoldMessengerKeyProvider),
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: (context, child) {
            final shouldShowPassCodeLockPage =
                ref.watch(shouldShowPassCodeLockPageProvider);
            return DevicePreview.appBuilder(
              context,
              Stack(
                children: [
                  child!,
                  // 必要な時にのみローディング画面を重ねて表示
                  if (ref.watch(loadingNotifierProvider))
                    const OverlayLoading(),
                  // 必要な時のみパスコードロック画面を重ねて表示
                  if (shouldShowPassCodeLockPage) const PassCodeLockPage(),
                ],
              ),
            );
          },
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
          home: const AuthPage(),
        );
      },
    );
  }
}
