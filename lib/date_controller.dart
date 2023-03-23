import 'package:hooks_riverpod/hooks_riverpod.dart';

final todayProvider = Provider<DateTime>((ref) => DateTime.now());

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final today = ref.watch(todayProvider);
  final selectedDate = DateTime(today.year, today.month, today.day);
  return selectedDate;
});

final dayOfWeekProvider = Provider<String>((ref) {
  final today = ref.watch(todayProvider);
  final dayOfWeekInt = today.weekday;
  final dayOfWeekStr = '日月火水木金土'[dayOfWeekInt];
  return dayOfWeekStr;
});

//当月の日数を返す
final daysInMonthProvider = Provider<int>((ref) {
  final today = ref.watch(todayProvider);
  //https://note.com/hatchoutschool/n/ne95862d50623
  final daysInMonth = DateTime(
    today.year,
    today.month + 1,
  ).add(const Duration(days: -1)).day;
  return daysInMonth;
});
