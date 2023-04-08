import 'package:flutter/material.dart';

extension TimeOfDayConverter on TimeOfDay {
  //TimeOfDayを24h表示に変換する
  String to24hours() {
    final hour = this.hour.toString().padLeft(2, '0');
    final min = minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }
}
