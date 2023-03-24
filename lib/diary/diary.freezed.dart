// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Diary _$DiaryFromJson(Map<String, dynamic> json) {
  return _Diary.fromJson(json);
}

/// @nodoc
mixin _$Diary {
  String get content => throw _privateConstructorUsedError;
  DateTime get diaryDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DiaryCopyWith<Diary> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiaryCopyWith<$Res> {
  factory $DiaryCopyWith(Diary value, $Res Function(Diary) then) =
      _$DiaryCopyWithImpl<$Res, Diary>;
  @useResult
  $Res call(
      {String content,
      DateTime diaryDate,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$DiaryCopyWithImpl<$Res, $Val extends Diary>
    implements $DiaryCopyWith<$Res> {
  _$DiaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? diaryDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      diaryDate: null == diaryDate
          ? _value.diaryDate
          : diaryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DiaryCopyWith<$Res> implements $DiaryCopyWith<$Res> {
  factory _$$_DiaryCopyWith(_$_Diary value, $Res Function(_$_Diary) then) =
      __$$_DiaryCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String content,
      DateTime diaryDate,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$_DiaryCopyWithImpl<$Res> extends _$DiaryCopyWithImpl<$Res, _$_Diary>
    implements _$$_DiaryCopyWith<$Res> {
  __$$_DiaryCopyWithImpl(_$_Diary _value, $Res Function(_$_Diary) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? diaryDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$_Diary(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      diaryDate: null == diaryDate
          ? _value.diaryDate
          : diaryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Diary implements _Diary {
  const _$_Diary(
      {required this.content,
      required this.diaryDate,
      required this.createdAt,
      required this.updatedAt})
      : assert(content.length > 16, '日記の本文が16文字以上になっています');

  factory _$_Diary.fromJson(Map<String, dynamic> json) =>
      _$$_DiaryFromJson(json);

  @override
  final String content;
  @override
  final DateTime diaryDate;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Diary(content: $content, diaryDate: $diaryDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Diary &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.diaryDate, diaryDate) ||
                other.diaryDate == diaryDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, content, diaryDate, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DiaryCopyWith<_$_Diary> get copyWith =>
      __$$_DiaryCopyWithImpl<_$_Diary>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DiaryToJson(
      this,
    );
  }
}

abstract class _Diary implements Diary {
  const factory _Diary(
      {required final String content,
      required final DateTime diaryDate,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$_Diary;

  factory _Diary.fromJson(Map<String, dynamic> json) = _$_Diary.fromJson;

  @override
  String get content;
  @override
  DateTime get diaryDate;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$_DiaryCopyWith<_$_Diary> get copyWith =>
      throw _privateConstructorUsedError;
}
