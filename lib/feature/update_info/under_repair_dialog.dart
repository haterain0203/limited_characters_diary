import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/update_info/update_info_service.dart';
import 'package:sizer/sizer.dart';

// メンテナンス中であることを表示するダイアログ
class UnderRepairDialog extends HookConsumerWidget {
  const UnderRepairDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateInfo = ref.watch(updateInfoProvider);

    // このダイアログは、緊急時以外ユーザーに見せないもの
    // loadingおよびエラーハンドリングは不要と考え、.whenは使っていない
    if (updateInfo.hasError ||
        updateInfo.value == null ||
        !updateInfo.value!.isUnderRepair) {
      return const SizedBox.shrink();
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
              updateInfo.value!.underRepairComment,
              style: TextStyle(
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
