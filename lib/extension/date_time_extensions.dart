import 'package:flutter/material.dart';

import '../constant/contant_date.dart';

extension DateTimeExtensions on DateTime {
  /// 曜日の文字列を返す
  String dayOfWeek() {
    return '月火水木金土日'[weekday - 1];
  }

  /// 土日祝日の場合なら色を、それ以外なら黒を返す
  Color choiceDayStrColor() {
    if (weekday == DateTime.saturday) {
      return Colors.blue;
    }
    if (weekday == DateTime.sunday) {
      return Colors.red;
    }
    if (ConstantDate.jpHolidayMap.containsKey(this)) {
      return Colors.red;
    }
    return Colors.black;
  }

  int daysInMonth() {
    //https://note.com/hatchoutschool/n/ne95862d50623
    final daysInMonth = DateTime(
      year,
      month + 1,
    ).add(const Duration(days: -1)).day;
    return daysInMonth;
  }

  bool isToday(DateTime indexDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return indexDate.isAtSameMomentAs(today);
  }
}
