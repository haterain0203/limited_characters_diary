import 'package:freezed_annotation/freezed_annotation.dart';

part 'diary.freezed.dart';
part 'diary.g.dart';

@freezed
class Diary with _$Diary {
  @Assert('content.length > 16', '日記の本文が16文字以上になっています')
  const factory Diary({
    required String content,
    required DateTime diaryDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Diary;

  factory Diary.fromJson(Map<String, dynamic> json) => _$DiaryFromJson(json);
}
