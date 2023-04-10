import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WebViewPage extends HookConsumerWidget {
  const WebViewPage({
    required this.flag,
    super.key,
  });

  final WebFlag flag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(true);
    final title = _setTitle(flag);
    final url = _setURL(flag);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          isLoading.value
              ? const LinearProgressIndicator(
                  minHeight: 8,
                )
              : const SizedBox(),
          Expanded(
            child: WebView(
              initialUrl: url,
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (_) {
                isLoading.value = false;
              },
            ),
          ),
        ],
      ),
    );
  }

  String _setTitle(WebFlag flag) {
    switch (flag) {
      case WebFlag.contact:
        return "お問合せ";
      case WebFlag.termsOfService:
        return "利用規約";
      case WebFlag.privacyPolicy:
        return "プライバシーポリシー";
    }
  }

  String _setURL(WebFlag flag) {
    switch (flag) {
      case WebFlag.contact:
        return "https://docs.google.com/forms/d/e/1FAIpQLSfWmqr_CnYiZlejcpMryTK4qEpQvP3TzABopwylvUWAazG2qg/viewform?usp=sf_link";
      case WebFlag.termsOfService:
        return "https://travelskill.jimdosite.com/%E5%88%A9%E7%94%A8%E8%A6%8F%E7%B4%84/";
      case WebFlag.privacyPolicy:
        return "https://travelskill.jimdosite.com/%E3%83%97%E3%83%A9%E3%82%A4%E3%83%90%E3%82%B7%E3%83%BC%E3%83%9D%E3%83%AA%E3%82%B7%E3%83%BC/";
    }
  }
}
