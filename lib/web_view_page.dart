import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    super.key,
    required this.title,
    required this.url,
  });
  final String title;
  final String url;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool _isLoading = true;
  WebViewController? webViewController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setWebViewController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(builder: (context) {
        if (_isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (_errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('エラー'),
                Text(_errorMessage!),
              ],
            ),
          );
        }
        return WebViewWidget(controller: webViewController!);
      }),
    );
  }

  void _setWebViewController() {
    webViewController = WebViewController()
      ..setBackgroundColor(Colors.black)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          // ページ読み込み中はインジケータを表示するために、_isLoadingをtrueに
          onPageStarted: (String url) => _startLoading(),
          // ページ完了後はインジケータを表示しないよう、_isLoadingをfalseに
          onPageFinished: (String url) => _endLoading(),
          // ページ読み込み中にエラーが発生した場合に、エラー内容をUI表示するために、_errorMessageにエラー内容をセットする
          onWebResourceError: (WebResourceError error) {
            debugPrint(error.description);
            _setErrorMessage(error);
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          widget.url,
        ),
      );
  }

  void _startLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void _endLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  void _setErrorMessage(WebResourceError error) {
    setState(() {
      _errorMessage = error.description;
      _isLoading = false;
    });
  }
}
