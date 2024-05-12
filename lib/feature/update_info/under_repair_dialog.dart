import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/component/error_page.dart';
import 'package:limited_characters_diary/feature/update_info/update_info_service.dart';
import 'package:sizer/sizer.dart';

// メンテナンス中であることを表示するダイアログ
class UnderRepairDialog extends HookConsumerWidget {
  const UnderRepairDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateInfo = ref.watch(updateInfoProvider);

    return updateInfo.when(
      error: (e, s) {
        return ErrorPage(error: e, stackTrace: s);
      },
      loading: () => const SizedBox.shrink(),
      data: (updateInfo) {
        if (!updateInfo.isUnderRepair) {
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
                  updateInfo.underRepairComment,
                  style: TextStyle(
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
