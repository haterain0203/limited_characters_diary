import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'date_controller.dart';

/// 今日の日付を提供する
/// 基本は外部から更新しないが、アプリから復帰した際に最新の日付に更新する
/// そのためにProviderではなくStateProvider
final todayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final selectedMonthDateProvider = StateProvider<DateTime>((ref) {
  final today = ref.watch(todayProvider);
  final selectedMonth = DateTime(
    today.year,
    today.month,
  );
  return selectedMonth;
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final today = ref.watch(todayProvider);
  final selectedDate = DateTime(today.year, today.month, today.day);
  return selectedDate;
});

final dateControllerProvider = Provider(
  (ref) => DateController(
    today: ref.watch(todayProvider),
    selectedDate: ref.watch(selectedDateProvider),
    selectedMonth: ref.watch(selectedMonthDateProvider),
    selectedMonthNotifier: ref.read(todayProvider.notifier),
  ),
);
