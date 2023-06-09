import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constant/constant_num.dart';

final dateControllerProvider = Provider.autoDispose(
  (ref) => DateController(
    selectedMonthDateTime: ref.watch(selectedMonthDateTimeProvider),
    hasJumpedToAroundToday: ref.watch(hasJumpedToAroundTodayProvider),
    hasJumpedToAroundTodayNotifier:
        ref.read(hasJumpedToAroundTodayProvider.notifier),
  ),
);

class DateController {
  DateController({
    required this.selectedMonthDateTime,
    required this.hasJumpedToAroundToday,
    required this.hasJumpedToAroundTodayNotifier,
  });

  final DateTime selectedMonthDateTime;
  final bool hasJumpedToAroundToday;
  final StateController<bool> hasJumpedToAroundTodayNotifier;

  /// 特定条件をクリアした場合、今日-5日に自動で画面スクロールする
  ///
  /// 月の後半になると、初期起動画面で該当日が表示されないことへの対応
  /// ほとんどの端末で15日程度は表示できると考えるため、当日が10日以下の場合はスクロールしない
  void maybeJumpToAroundToday(ScrollController scrollController) {
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
    if (selectedMonthDateTime.month != today.month) {
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

// このProviderは現在選択されている「月」を管理する。
// 'DateTime'型を使用しているが、これは年と月の計算（例：12月の次の月が翌年の1月になる）を容易にするため。
// このProviderの主な目的は「月」の管理であり、日付や時刻の情報は基本的には使用されない。
// 時間以下は確実に使用しないため、年月日以下のDateTimeを返す。
// 'selectedMonthDateTimeProvider'という名前は、この事実を明示的に示すために使用。
final selectedMonthDateTimeProvider = StateProvider((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// 日記入力する際に選択された日付を管理する。
// 時間以下は確実に使用しないため、年月日だけのDateTimeを返す。
final selectedDateTimeProvider = StateProvider((ref) {
    final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final hasJumpedToAroundTodayProvider = StateProvider((ref) => false);
