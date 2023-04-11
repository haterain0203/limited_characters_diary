// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Diary _$$_DiaryFromJson(Map<String, dynamic> json) => _$_Diary(
      content: json['content'] as String,
      diaryDate:
          const DateTimeConverter().fromJson(json['diaryDate'] as Timestamp),
      createdAt:
          const DateTimeConverter().fromJson(json['createdAt'] as Timestamp),
      updatedAt:
          const DateTimeConverter().fromJson(json['updatedAt'] as Timestamp),
    );

Map<String, dynamic> _$$_DiaryToJson(_$_Diary instance) => <String, dynamic>{
      'content': instance.content,
      'diaryDate': const DateTimeConverter().toJson(instance.diaryDate),
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const DateTimeConverter().toJson(instance.updatedAt),
    };
