import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../tool/DateTimeConverter.dart';

part 'diary.freezed.dart';
part 'diary.g.dart';

@freezed
class Diary with _$Diary {
  //TODO これだと思った通りに動作しない。書き方が間違っている可能性。
  // @Assert('content.length > 16', '日記の本文が16文字以上になっています')
  const factory Diary({
    required String content,
    @DateTimeConverter() required DateTime diaryDate,
    @DateTimeConverter() required DateTime createdAt,
    @DateTimeConverter() required DateTime updatedAt,
  }) = _Diary;

  factory Diary.fromJson(Map<String, dynamic> json) => _$DiaryFromJson(json);
}
