import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constant/constant_string.dart';
import '../../../web_view_page.dart';
import '../auth/auth_page.dart';

final routingControllerProvider = Provider((_) => RoutingController());

class RoutingController {
  Future<void> goTermsOfServiceOnWebView(BuildContext context) async {
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

  Future<void> goAuthPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute<AuthPage>(
        builder: (_) => const AuthPage(),
      ),
    );
  }
}
