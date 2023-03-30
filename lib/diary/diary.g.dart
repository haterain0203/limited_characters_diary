// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Diary _$$_DiaryFromJson(Map<String, dynamic> json) => _$_Diary(
      content: json['content'] as String,
      diaryDate: DateTime.parse(json['diaryDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$_DiaryToJson(_$_Diary instance) => <String, dynamic>{
      'content': instance.content,
      'diaryDate': instance.diaryDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
