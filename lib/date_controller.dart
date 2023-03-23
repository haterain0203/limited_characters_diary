import 'package:hooks_riverpod/hooks_riverpod.dart';

final todayProvider = Provider<DateTime>((ref) => DateTime.now());

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final today = ref.watch(todayProvider);
  final selectedDate = DateTime(today.year, today.month, today.day);
  return selectedDate;
});

final dateControllerProvider = Provider((ref) => DateController(ref: ref));

class DateController {
  DateController({required this.ref});
  final ProviderRef<dynamic> ref;

  DateTime get today => ref.watch(todayProvider);
  DateTime get selectedDate => ref.watch(selectedDateProvider);

  String searchDayOfWeek(int day) {
    final selectedDay = DateTime(selectedDate.year, selectedDate.month, day);
    final dayOfWeekInt = selectedDay.weekday;
    final dayOfWeekStr = '月火水木金土日'[dayOfWeekInt - 1];
    return dayOfWeekStr;
  }

  //当月の日数を返す
  int daysInMonth() {
    //https://note.com/hatchoutschool/n/ne95862d50623
    final daysInMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
    ).add(const Duration(days: -1)).day;
    return daysInMonth;
  }

  void changeDateStrColor(int day) {
    final selectedDate = DateTime(day);
  }
}
