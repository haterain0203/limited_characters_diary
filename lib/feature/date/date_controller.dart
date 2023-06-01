import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../diary/diary.dart';

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

  void showNextMonth() {
    selectedMonthNotifier.update((state) {
      return DateTime(
        selectedMonth.year,
        selectedMonth.month + 1,
      );
    });
  }

  void showPreviousMonth() {
    selectedMonthNotifier.update((state) {
      return DateTime(
        selectedMonth.year,
        selectedMonth.month - 1,
      );
    });
  }

  //TODO check 選択された月の状態が必要なため、extensionではなくcontrollerとしたがどうか？
  int daysInMonth() {
    //https://note.com/hatchoutschool/n/ne95862d50623
    final daysInMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
    ).add(const Duration(days: -1)).day;
    return daysInMonth;
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

  bool _isThisMonth() {
    return selectedMonth.month == today.month;
  }

  /// 今日-5日に自動で画面スクロールするかどうか
  bool isJumpToAroundToday() {
    if (!_isThisMonth()) {
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
}
