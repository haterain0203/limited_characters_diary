import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../component/stadium_border_button.dart';
import '../../constant/enum.dart';
import '../admob/ad_controller.dart';
import 'diary_service.dart';

class CompleteDialogContent extends HookConsumerWidget {
  const CompleteDialogContent({
    required this.inputDiaryType,
    super.key,
  });

  final InputDiaryType inputDiaryType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryCount = ref.watch(diaryCountProvider);
    return diaryCount.when(
      error: (e, s) => Text(e.toString()),
      loading: CircularProgressIndicator.new,
      data: (data) {
        return Column(
          children: [
            Text(
              inputDiaryType == InputDiaryType.add ? '登録完了！' : '更新完了！',
              style: TextStyle(fontSize: 16.sp),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              '$data個目の記録です',
              style: TextStyle(fontSize: 14.sp),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: StadiumBorderButton(
                  onPressed: () async {
                    //TODO check ここに限った話ではないが、DialogにDialogを重ねるのは問題ないか？
                    Navigator.pop(context);
                    Navigator.pop(context);
                    // 更新の場合全画面広告は表示しない
                    if (inputDiaryType == InputDiaryType.update) {
                      return;
                    }
                    // 日記の記録数が3の倍数の場合、全画面広告を出す
                    if (data % 3 == 0) {
                      await ref
                          .read(adControllerProvider)
                          .showInterstitialAdd();
                      //TODO check 以下の処理はController内に記述すべきか？
                      //TODO Controllerのメソッドの責務が2つになってしまうため望ましくないか？
                      ref.read(isShownInterstitialAdProvider.notifier).state =
                          true;
                    }
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        );
      },
    );
  }
}