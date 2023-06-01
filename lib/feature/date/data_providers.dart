import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'date_controller.dart';

/// 今日の日付を提供する
/// 基本は外部から更新しないが、アプリから復帰した際に最新の日付に更新する
/// そのためにProviderではなくStateProvider
//TODO check StateProviderで問題ないか？
final todayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime(2023, 5, 25);
  return DateTime(now.year, now.month, now.day);
});

final selectedMonthDateProvider = StateProvider<DateTime>((ref) {
  // 初期値は本日が属する月
  final today = ref.watch(todayProvider);
  final selectedMonth = DateTime(
    today.year,
    today.month,
  );
  return selectedMonth;
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  // 初期値は本日の日付
  final today = ref.watch(todayProvider);
  final selectedDate = DateTime(today.year, today.month, today.day);
  return selectedDate;
});

final dateControllerProvider = Provider.autoDispose(
  (ref) => DateController(
    today: ref.watch(todayProvider),
    selectedDate: ref.watch(selectedDateProvider),
    selectedMonth: ref.watch(selectedMonthDateProvider),
    todayNotifier: ref.read(todayProvider.notifier),
    selectedMonthNotifier: ref.read(selectedMonthDateProvider.notifier),
  ),
);
