import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/link_with_social_account/link_with_social_account_page.dart';
import 'package:limited_characters_diary/feature/setting/setting_page.dart';

import '../../../constant/constant_string.dart';
import '../../../web_view_page.dart';
import '../auth/auth_page.dart';
import '../auth/login_page.dart';

final routingControllerProvider =
    Provider.autoDispose.family<RoutingController, BuildContext>(
  (ref, context) => RoutingController(context: context),
);

class RoutingController {
  RoutingController({required this.context});

  final BuildContext context;

  Future<void> goTermsOfServiceOnWebView() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const WebViewPage(
          title: ConstantString.termsOfServiceStr,
          url: ConstantString.termsOfServiceUrl,
        ),
        settings: const RouteSettings(name: '/termsOfService'),
      ),
    );
  }

  Future<void> goContactUsOnWebView({required String url}) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => WebViewPage(
          title: ConstantString.contactUsStr,
          url: url,
        ),
        settings: const RouteSettings(name: '/contactUs'),
      ),
    );
  }

  Future<void> goPrivacyPolicyOnWebView() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const WebViewPage(
          title: ConstantString.privacyPolicyStr,
          url: ConstantString.privacyPolicyUrl,
        ),
        settings: const RouteSettings(name: '/privacyPolicy'),
      ),
    );
  }

  Future<void> goAuthPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const AuthPage(),
        settings: const RouteSettings(name: '/auth'),
      ),
    );
  }

  Future<void> goLoginPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const LoginPage(),
        settings: const RouteSettings(name: '/login'),
      ),
    );
  }

  /// ログインページへ遷移し、ナビゲーションスタック上のすべてのルートを削除します。
  /// これはユーザーがログアウトした後に使用され、以前のページに戻ることができないようにします。
  Future<void> goAndRemoveUntilLoginPage() async {
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const LoginPage(),
        settings: const RouteSettings(name: '/login'),
      ),
      (Route<dynamic> route) => false, // すべてのルートを削除する条件
    );
  }

  Future<void> goSettingPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const SettingPage(),
        settings: const RouteSettings(name: '/settings'),
      ),
    );
  }

  Future<void> goLinkWithSocialAccountPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const LinkWithSocialAccountPage(),
        settings: const RouteSettings(name: '/linkWithSocialAccount'),
      ),
    );
  }
}
