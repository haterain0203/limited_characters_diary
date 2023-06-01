import 'package:flutter/material.dart';

import '../constant/contant_date.dart';

extension DateTimeExtensions on DateTime {
  /// 曜日の文字列を返す
  String searchDayOfWeek(DateTime indexDate) {
    final dayOfWeekInt = indexDate.weekday;
    final dayOfWeekStr = '月火水木金土日'[dayOfWeekInt - 1];
    return dayOfWeekStr;
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
    if (ConstantDate.jpHolidayMap.containsKey(indexDate)) {
      return Colors.red;
    }
    return Colors.black;
  }
}