import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

//参考にしたURL
//https://qiita.com/tetsufe/items/3c7d997f1c13c659628c
//https://zenn.dev/tokku5552/articles/json_converter_freezed
class DateTimeConverter implements JsonConverter<DateTime, Timestamp> {
  const DateTimeConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}

// class DateTimeConverter implements JsonConverter<DateTime, String> {
//   const DateTimeConverter();
//
//   @override
//   DateTime fromJson(String json) {
//     return DateTime.parse(json).toLocal();
//   }
//
//   @override
//   String toJson(DateTime dateTime) {
//     return dateTime.toLocal().toString();
//   }
// }