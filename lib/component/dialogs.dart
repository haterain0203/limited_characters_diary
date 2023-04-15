import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/component/stadium_border_button.dart';
import 'package:sizer/sizer.dart';

import '../feature/update_info/update_info_providers.dart';

class ForcedUpdateDialog extends HookConsumerWidget {
  const ForcedUpdateDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 強制アップデートダイアログを表示するかどうかのflag
    final isForcedUpdate = ref.watch(forcedUpdateProvider);

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
            onPressed: () {
              //TODO ストアへ遷移
              Navigator.pop(context);
            },
            title: 'アプリストアへ',
          ),
        ),
      ],
    );
  }
}

class OnlyCloseDialog extends StatelessWidget {
  const OnlyCloseDialog({
    required this.title,
    this.content,
    super.key,
  });

  final String title;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content,
      actions: [
        StadiumBorderButton(
          onPressed: () {
            Navigator.pop(context);
          },
          title: '閉じる',
        ),
      ],
    );
  }
}
