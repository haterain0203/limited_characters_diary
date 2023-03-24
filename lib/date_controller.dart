import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final todayProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

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

  Color choiceDayStrColor(int day) {
    final selectedDay = DateTime(selectedDate.year, selectedDate.month, day);
    if (jpHolidayMap.containsKey(selectedDay)) {
      return Colors.red;
    }
    final dayOfWeekInt = selectedDay.weekday;
    if (dayOfWeekInt == DateTime.saturday) {
      return Colors.blue;
    }
    if (dayOfWeekInt == DateTime.sunday) {
      return Colors.red;
    }
    return Colors.black;
  }

  bool isToday(int day) {
    final selectedDay = DateTime(selectedDate.year, selectedDate.month, day);
    return selectedDay.isAtSameMomentAs(today);
  }

  //2029年までの日本の祝日 20230324時点
  //以下のデータを加工
  //https://github.com/holiday-jp/holiday_jp/blob/master/holidays.yml
  final Map<DateTime, String> jpHolidayMap = {
    DateTime(2023, 01, 01): '元日',
    DateTime(2023, 01, 02): '元日振替休日',
    DateTime(2023, 01, 09): '成人の日',
    DateTime(2023, 02, 11): '建国記念の日',
    DateTime(2023, 02, 23): '天皇誕生日',
    DateTime(2023, 03, 21): '春分の日',
    DateTime(2023, 04, 29): '昭和の日',
    DateTime(2023, 05, 03): '憲法記念日',
    DateTime(2023, 05, 04): 'みどりの日',
    DateTime(2023, 05, 05): 'こどもの日',
    DateTime(2023, 07, 17): '海の日',
    DateTime(2023, 08, 11): '山の日',
    DateTime(2023, 09, 18): '敬老の日',
    DateTime(2023, 09, 23): '秋の分の日',
    DateTime(2023, 10, 09): 'スポーツの日',
    DateTime(2023, 11, 03): '文化の日',
    DateTime(2023, 11, 23): '勤労感謝の日',
    DateTime(2024, 01, 01): '元日',
    DateTime(2024, 01, 08): '成人の日',
    DateTime(2024, 02, 11): '建国記念の日',
    DateTime(2024, 02, 12): '建国記念の日 振替休日',
    DateTime(2024, 02, 23): '天皇誕生日',
    DateTime(2024, 03, 20): '春分の日',
    DateTime(2024, 04, 29): '昭和の日',
    DateTime(2024, 05, 03): '憲法記念日',
    DateTime(2024, 05, 04): 'みどりの日',
    DateTime(2024, 05, 05): 'こどもの日',
    DateTime(2024, 05, 06): 'こどもの日振替休日',
    DateTime(2024, 07, 15): '海の日',
    DateTime(2024, 08, 11): '山の日',
    DateTime(2024, 08, 12): '山の日振替休日',
    DateTime(2024, 09, 16): '敬老の日',
    DateTime(2024, 09, 22): '秋の分の日',
    DateTime(2024, 09, 23): '秋の分の日振替休日',
    DateTime(2024, 10, 14): 'スポーツの日',
    DateTime(2024, 11, 03): '文化の日',
    DateTime(2024, 11, 04): '文化の日振替休日',
    DateTime(2024, 11, 23): '勤労感謝の日',
    DateTime(2025, 01, 01): '元日',
    DateTime(2025, 01, 13): '成人の日',
    DateTime(2025, 02, 11): '建国記念の日',
    DateTime(2025, 02, 23): '天皇誕生日',
    DateTime(2025, 02, 24): '天皇誕生日振替休日',
    DateTime(2025, 03, 20): '春分の日',
    DateTime(2025, 04, 29): '昭和の日',
    DateTime(2025, 05, 03): '憲法記念日',
    DateTime(2025, 05, 04): 'みどりの日',
    DateTime(2025, 05, 05): 'こどもの日',
    DateTime(2025, 05, 06): 'こどもの日振替休日',
    DateTime(2025, 07, 21): '海の日',
    DateTime(2025, 08, 11): '山の日',
    DateTime(2025, 09, 15): '敬老の日',
    DateTime(2025, 09, 23): '秋の分の日',
    DateTime(2025, 10, 13): 'スポーツの日',
    DateTime(2025, 11, 03): '文化の日',
    DateTime(2025, 11, 23): '勤労感謝の日',
    DateTime(2025, 11, 24): '勤労感謝の日振替休日',
    DateTime(2026, 01, 01): '元日',
    DateTime(2026, 01, 12): '成人の日',
    DateTime(2026, 02, 11): '建国記念の日',
    DateTime(2026, 02, 23): '天皇誕生日',
    DateTime(2026, 03, 20): '春分の日',
    DateTime(2026, 04, 29): '昭和の日',
    DateTime(2026, 05, 03): '憲法記念日',
    DateTime(2026, 05, 04): 'みどりの日',
    DateTime(2026, 05, 05): 'こどもの日',
    DateTime(2026, 05, 06): 'こどもの日振替休日',
    DateTime(2026, 07, 20): '海の日',
    DateTime(2026, 08, 11): '山の日',
    DateTime(2026, 09, 21): '敬老の日',
    DateTime(2026, 09, 22): '休日',
    DateTime(2026, 09, 23): '秋の分の日',
    DateTime(2026, 10, 12): 'スポーツの日',
    DateTime(2026, 11, 03): '文化の日',
    DateTime(2026, 11, 23): '勤労感謝の日',
    DateTime(2027, 01, 01): '元日',
    DateTime(2027, 01, 11): '成人の日',
    DateTime(2027, 02, 11): '建国記念の日',
    DateTime(2027, 02, 23): '天皇誕生日',
    DateTime(2027, 03, 21): '春分の日',
    DateTime(2027, 03, 22): '春分の日振替休日',
    DateTime(2027, 04, 29): '昭和の日',
    DateTime(2027, 05, 03): '憲法記念日',
    DateTime(2027, 05, 04): 'みどりの日',
    DateTime(2027, 05, 05): 'こどもの日',
    DateTime(2027, 07, 19): '海の日',
    DateTime(2027, 08, 11): '山の日',
    DateTime(2027, 09, 20): '敬老の日',
    DateTime(2027, 09, 23): '秋の分の日',
    DateTime(2027, 10, 11): 'スポーツの日',
    DateTime(2027, 11, 03): '文化の日',
    DateTime(2027, 11, 23): '勤労感謝の日',
    DateTime(2028, 01, 01): '元日',
    DateTime(2028, 01, 10): '成人の日',
    DateTime(2028, 02, 11): '建国記念の日',
    DateTime(2028, 02, 23): '天皇誕生日',
    DateTime(2028, 03, 20): '春分の日',
    DateTime(2028, 04, 29): '昭和の日',
    DateTime(2028, 05, 03): '憲法記念日',
    DateTime(2028, 05, 04): 'みどりの日',
    DateTime(2028, 05, 05): 'こどもの日',
    DateTime(2028, 07, 17): '海の日',
    DateTime(2028, 08, 11): '山の日',
    DateTime(2028, 09, 18): '敬老の日',
    DateTime(2028, 09, 22): '秋の分の日',
    DateTime(2028, 10, 09): 'スポーツの日',
    DateTime(2028, 11, 03): '文化の日',
    DateTime(2028, 11, 23): '勤労感謝の日',
    DateTime(2029, 01, 01): '元日',
    DateTime(2029, 01, 08): '成人の日',
    DateTime(2029, 02, 11): '建国記念の日',
    DateTime(2029, 02, 12): '建国記念の日 振替休日',
    DateTime(2029, 02, 23): '天皇誕生日',
    DateTime(2029, 03, 20): '春分の日',
    DateTime(2029, 04, 29): '昭和の日',
    DateTime(2029, 04, 30): '昭和の日振替休日',
    DateTime(2029, 05, 03): '憲法記念日',
    DateTime(2029, 05, 04): 'みどりの日',
    DateTime(2029, 05, 05): 'こどもの日',
    DateTime(2029, 07, 16): '海の日',
    DateTime(2029, 08, 11): '山の日',
    DateTime(2029, 09, 17): '敬老の日',
    DateTime(2029, 09, 23): '秋の分の日',
    DateTime(2029, 09, 24): '秋の分の日振替休日',
    DateTime(2029, 10, 08): 'スポーツの日',
    DateTime(2029, 11, 03): '文化の日',
    DateTime(2029, 11, 23): '勤労感謝の日',
  };
}
