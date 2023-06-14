import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/setting/setting_page.dart';

import '../../../constant/constant_string.dart';
import '../../../web_view_page.dart';
import '../auth/auth_page.dart';

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
      MaterialPageRoute<WebViewPage>(
        builder: (context) => const WebViewPage(
          title: ConstantString.termsOfServiceStr,
          url: ConstantString.termsOfServiceUrl,
        ),
      ),
    );
  }

  Future<void> goContactUsOnWebView() async {
    await Navigator.push(
      context,
      MaterialPageRoute<WebViewPage>(
        builder: (context) => const WebViewPage(
          title: ConstantString.contactUsStr,
          url: ConstantString.googleFormUrl,
        ),
      ),
    );
  }

  Future<void> goPrivacyPolicyOnWebView() async {
    await Navigator.push(
      context,
      MaterialPageRoute<WebViewPage>(
        builder: (context) => const WebViewPage(
          title: ConstantString.privacyPolicyStr,
          url: ConstantString.privacyPolicyUrl,
        ),
      ),
    );
  }

  Future<void> goAuthPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute<AuthPage>(
        builder: (_) => const AuthPage(),
      ),
    );
  }

  Future<void> goSettingPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute<SettingPage>(
        builder: (_) => const SettingPage(),
      ),
    );
  }
}
