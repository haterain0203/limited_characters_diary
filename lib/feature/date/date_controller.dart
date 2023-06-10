import 'package:hooks_riverpod/hooks_riverpod.dart';

final dateControllerProvider = Provider.autoDispose(
  (ref) => DateController(
    selectedDateTime: ref.watch(selectedDateTimeProvider),
    hasJumpedToAroundToday: ref.watch(hasJumpedToAroundTodayProvider),
  ),
);

class DateController {
  DateController({
    required this.selectedDateTime,
    required this.hasJumpedToAroundToday,
  });

  final DateTime selectedDateTime;
  final bool hasJumpedToAroundToday;

  /// 今日-5日に自動で画面スクロールするかどうか
  bool shouldJumpToAroundToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // 既にスクロール済みならfalseを返す（スクロールさせない）
    if (hasJumpedToAroundToday) {
      return false;
    }
    if (selectedDateTime.month != today.month) {
      return false;
    }
    if (today.day <= 10) {
      return false;
    }
    return true;
  }
}

final selectedDateTimeProvider = StateProvider((ref) => DateTime.now());

final hasJumpedToAroundTodayProvider = StateProvider((ref) => false);
