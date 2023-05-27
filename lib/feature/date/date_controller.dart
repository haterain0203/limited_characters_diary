import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../diary/diary.dart';

//TODO check 各メソッドはControllerに記載すべきか否か？
class DateController {
  DateController({
    required this.today,
    required this.selectedDate,
    required this.selectedMonth,
    required this.todayNotifier,
    required this.selectedMonthNotifier,
  });

  final DateTime today;
  final DateTime selectedDate;
  final DateTime selectedMonth;
  final StateController<DateTime> todayNotifier;
  final StateController<DateTime> selectedMonthNotifier;

  void nextMonth() {
    selectedMonthNotifier.update((state) {
      return DateTime(
        selectedMonth.year,
        selectedMonth.month + 1,
      );
    });
  }

  void previousMonth() {
    selectedMonthNotifier.update((state) {
      return DateTime(
        selectedMonth.year,
        selectedMonth.month - 1,
      );
    });
  }

  /// 曜日の文字列を返す
  String searchDayOfWeek(DateTime indexDate) {
    final dayOfWeekInt = indexDate.weekday;
    final dayOfWeekStr = '月火水木金土日'[dayOfWeekInt - 1];
    return dayOfWeekStr;
  }

  /// 当月の日数を返す
  int daysInMonth() {
    //https://note.com/hatchoutschool/n/ne95862d50623
    final daysInMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
    ).add(const Duration(days: -1)).day;
    return daysInMonth;
  }

  /// 土日祝日の場合なら色を、それ以外なら黒を返す
  Color choiceDayStrColor(DateTime indexDate) {
    final dayOfWeekInt = indexDate.weekday;
    if (dayOfWeekInt == DateTime.saturday) {
      return Colors.blue;
    }
    if (dayOfWeekInt == DateTime.sunday) {
      return Colors.red;
    }
    if (jpHolidayMap.containsKey(indexDate)) {
      return Colors.red;
    }
    return Colors.black;
  }

  bool isToday(DateTime indexDate) {
    return indexDate.isAtSameMomentAs(today);
  }

  /// inactive時とresume時で日付が変わっている場合更新する
  void updateToday(DateTime now) {
    todayNotifier.update((state) {
      return DateTime(now.year, now.month, now.day);
    });
  }

  bool isThisMonth() {
    return selectedMonth.month == today.month;
  }

  /// 今日-5日に自動で画面スクロールするかどうか
  bool isJumpToAroundToday() {
    if (!isThisMonth()) {
      return false;
    }
    if (today.day <= 10) {
      return false;
    }
    return true;
  }

  /// ListViewのindexに該当する日付を返す
  DateTime indexToDateTime(int index) {
    return DateTime(
      selectedMonth.year,
      selectedMonth.month,
      index + 1,
    );
  }

  /// ListViewのindexに該当する日記を返す
  Diary? getIndexDateDiary(List<Diary> diaryList, DateTime indexDate) {
    final indexDateDiary = diaryList.firstWhereOrNull((diary) {
      return diary.diaryDate == indexDate;
    });
    return indexDateDiary;
  }

  //TODO check データの持ち方として適切か？
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
