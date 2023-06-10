import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

  Future<void> goAuthPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute<AuthPage>(
        builder: (_) => const AuthPage(),
      ),
    );
  }
}
