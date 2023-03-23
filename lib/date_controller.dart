import 'package:hooks_riverpod/hooks_riverpod.dart';

final todayProvider = Provider<DateTime>((ref) => DateTime.now());

final dayOfWeekProvider = Provider<String>((ref) {
  final today = ref.watch(todayProvider);
  final dayOfWeekInt = today.weekday;
  final dayOfWeekStr = '日月火水木金土'[dayOfWeekInt];
  return dayOfWeekStr;
});
