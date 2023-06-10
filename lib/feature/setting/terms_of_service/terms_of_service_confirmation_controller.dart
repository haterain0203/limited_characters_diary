import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constant/constant_string.dart';
import '../../../web_view_page.dart';

final termsOfServiceConfirmationControllerProvider =
    Provider((_) => TermsOfServiceConfirmationController());

class TermsOfServiceConfirmationController {
  void goTermsOfServiceOnWebView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<WebViewPage>(
        builder: (context) => const WebViewPage(
          title: ConstantString.termsOfServiceStr,
          url: ConstantString.termsOfServiceUrl,
        ),
      ),
    );
  }
}
