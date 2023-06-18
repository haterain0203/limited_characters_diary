import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constant/constant_num.dart';

final dateControllerProvider = Provider.autoDispose(
  (ref) => DateController(
    selectedDateTime: ref.watch(selectedDateTimeProvider),
    hasJumpedToAroundToday: ref.watch(hasJumpedToAroundTodayProvider),
    hasJumpedToAroundTodayNotifier:
        ref.read(hasJumpedToAroundTodayProvider.notifier),
  ),
);

class DateController {
  DateController({
    required this.selectedDateTime,
    required this.hasJumpedToAroundToday,
    required this.hasJumpedToAroundTodayNotifier,
  });

  final DateTime selectedDateTime;
  final bool hasJumpedToAroundToday;
  final StateController<bool> hasJumpedToAroundTodayNotifier;

  /// 特定条件をクリアした場合、今日-5日に自動で画面スクロールする
  ///
  /// 月の後半になると、初期起動画面で該当日が表示されないことへの対応
  /// ほとんどの端末で15日程度は表示できると考えるため、当日が10日以下の場合はスクロールしない
  void jumpToAroundToday(ScrollController scrollController) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // 既にスクロール済みなら処理終了
    if (hasJumpedToAroundToday) {
      return;
    }
    if (!scrollController.hasClients) {
      return;
    }
    // 今月以外を表示している場合は処理終了
    if (selectedDateTime.month != today.month) {
      return;
    }
    // アプリ起動日が10日未満なら処理終了
    if (today.day <= 10) {
      return;
    }
    // スクロール済みであることをフラグ管理
    hasJumpedToAroundTodayNotifier.state = true;
    // 自動スクロール
    // -5としているのは、当日を一番上にするよりも当日の4日前まで見れた方が良いと考えたため
    return scrollController.jumpTo(
      ConstantNum.sizedListTileHeight * (today.day - 5),
    );
  }
}

final selectedDateTimeProvider = StateProvider((ref) => DateTime.now());

final hasJumpedToAroundTodayProvider = StateProvider((ref) => false);
