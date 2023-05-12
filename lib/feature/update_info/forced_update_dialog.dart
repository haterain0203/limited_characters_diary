import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/update_info/update_info_providers.dart';
import 'package:sizer/sizer.dart';

import '../../component/stadium_border_button.dart';
import '../../constant/constant.dart';
import '../link_to_app_or_web/link_to_app_or_web.dart';

class ForcedUpdateDialog extends HookConsumerWidget {
  const ForcedUpdateDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isForcedUpdate = ref.watch(forcedUpdateProvider);

    // このダイアログは、緊急時以外ユーザーに見せないもの
    // loadingおよびエラーハンドリングは不要と考え、.whenは使っていない
    if (isForcedUpdate.value == null || !isForcedUpdate.value!) {
      return const SizedBox();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: Colors.grey.withOpacity(0.65),
        ),
        AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '最新版がリリースされています。\nアップデートをお願いします。',
              style: TextStyle(
                fontSize: 13.sp,
              ),
            ),
          ),
          content: StadiumBorderButton(
            onPressed: () async {
              final url = Platform.isAndroid
                  ? Constant.playStoreUrl
                  : Constant.appStoreUrl;
              await linkToAppOrWeb(url);
            },
            title: const Text('アプリストアへ'),
          ),
        ),
      ],
    );
  }
}
