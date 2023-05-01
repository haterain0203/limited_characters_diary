import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/constant.dart';
import 'package:limited_characters_diary/feature/auth/auth_page.dart';
import 'package:limited_characters_diary/feature/first_launch/first_launch_providers.dart';
import 'package:limited_characters_diary/list_page.dart';
import 'package:limited_characters_diary/web_view_page.dart';

class TermsOfServiceConfirmationPage extends StatelessWidget {
  const TermsOfServiceConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              //TODO
              'アプリ名が入ります',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 36,
            ),
            const Text(
              '利用規約に同意',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('アプリを始めるには利用規約の同意が必要です。'),
            ),
            TextButton(
              child: const Text('利用規約を確認'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<WebViewPage>(
                  builder: (context) => const WebViewPage(
                    title: Constant.termsOfServiceStr,
                    url: Constant.termsOfServiceUrl,
                  ),
                ),
              ),
            ),
            HookConsumer(
              builder: (context, ref, child) => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('利用規約に同意'),
                ),
                onPressed: () async {
                  await ref.read(firstLaunchControllerProvider).completedFirstLaunch();
                  if(context.mounted) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute<ListPage>(
                        builder: (context) => const AuthPage(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
