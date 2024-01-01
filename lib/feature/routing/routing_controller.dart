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

/// `RoutingController` はアプリ内のナビゲーションを管理するクラスです。
/// 
/// このクラスは、さまざまなページへの遷移を担当し、ナビゲーションロジックを集約します。
class RoutingController {
  RoutingController({required this.context});

  final BuildContext context;

  /// 利用規約ページへ遷移します。
  /// 
  /// WebViewを使用して利用規約の内容を表示します。
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

  /// お問い合わせページへ遷移します。
  /// 
  /// 引数 `url` で指定されたURLをWebViewで表示します。
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

  /// プライバシーポリシーページへ遷移します。
  /// 
  /// WebViewを使用してプライバシーポリシーの内容を表示します。
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

  /// 認証ページへ遷移します。
  Future<void> goAuthPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const AuthPage(),
        settings: const RouteSettings(name: '/auth'),
      ),
    );
  }

  /// ログインページへ遷移します。
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
  /// 
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

  /// 設定ページへ遷移します。
  Future<void> goSettingPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const SettingPage(),
        settings: const RouteSettings(name: '/settings'),
      ),
    );
  }

  /// ソーシャルアカウントとのリンクページへ遷移します。
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
