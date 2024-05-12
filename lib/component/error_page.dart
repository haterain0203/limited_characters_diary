import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/constant_string.dart';

import '../feature/routing/routing_controller.dart';
import '../feature/setting/setting_controller.dart';

class ErrorPage extends HookConsumerWidget {
  const ErrorPage({
    required this.error,
    required this.stackTrace,
    super.key,
  });

  final Object error;
  final StackTrace stackTrace;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('エラー'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SelectableText(
                'エラーが発生しました。\n\n'
                'お手数をおかけしますが、\n'
                '時間を空けてアプリを再起動してください。\n\n'
                '問題が解決しない場合は画面最下部の「問い合わせ」ボタンからお問合せをお願いします。\n\n'
                '＜エラー内容＞\n'
                '$error\n\n'
                '＜StackTrace＞\n'
                '$stackTrace',
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final contactUsUrl = await ref
                      .read(settingControllerProvider)
                      .createContactUsUrl();
                  await ref
                      .read(routingControllerProvider)
                      .goContactUsOnWebView(
                        url: contactUsUrl,
                      );
                },
                child: const Text(ConstantString.contactUsStr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
