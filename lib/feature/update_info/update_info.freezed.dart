// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

UpdateInfo _$UpdateInfoFromJson(Map<String, dynamic> json) {
  return _UpdateInfo.fromJson(json);
}

/// @nodoc
mixin _$UpdateInfo {
  bool get requiredUpdate => throw _privateConstructorUsedError;
  String get requiredIosVersion => throw _privateConstructorUsedError;
  String get requiredAndroidVersion => throw _privateConstructorUsedError;
  bool get isUnderRepair => throw _privateConstructorUsedError;
  String get underRepairComment => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateInfoCopyWith<UpdateInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateInfoCopyWith<$Res> {
  factory $UpdateInfoCopyWith(
          UpdateInfo value, $Res Function(UpdateInfo) then) =
      _$UpdateInfoCopyWithImpl<$Res, UpdateInfo>;
  @useResult
  $Res call(
      {bool requiredUpdate,
      String requiredIosVersion,
      String requiredAndroidVersion,
      bool isUnderRepair,
      String underRepairComment});
}

/// @nodoc
class _$UpdateInfoCopyWithImpl<$Res, $Val extends UpdateInfo>
    implements $UpdateInfoCopyWith<$Res> {
  _$UpdateInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requiredUpdate = null,
    Object? requiredIosVersion = null,
    Object? requiredAndroidVersion = null,
    Object? isUnderRepair = null,
    Object? underRepairComment = null,
  }) {
    return _then(_value.copyWith(
      requiredUpdate: null == requiredUpdate
          ? _value.requiredUpdate
          : requiredUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      requiredIosVersion: null == requiredIosVersion
          ? _value.requiredIosVersion
          : requiredIosVersion // ignore: cast_nullable_to_non_nullable
              as String,
      requiredAndroidVersion: null == requiredAndroidVersion
          ? _value.requiredAndroidVersion
          : requiredAndroidVersion // ignore: cast_nullable_to_non_nullable
              as String,
      isUnderRepair: null == isUnderRepair
          ? _value.isUnderRepair
          : isUnderRepair // ignore: cast_nullable_to_non_nullable
              as bool,
      underRepairComment: null == underRepairComment
          ? _value.underRepairComment
          : underRepairComment // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_UpdateInfoCopyWith<$Res>
    implements $UpdateInfoCopyWith<$Res> {
  factory _$$_UpdateInfoCopyWith(
          _$_UpdateInfo value, $Res Function(_$_UpdateInfo) then) =
      __$$_UpdateInfoCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool requiredUpdate,
      String requiredIosVersion,
      String requiredAndroidVersion,
      bool isUnderRepair,
      String underRepairComment});
}

/// @nodoc
class __$$_UpdateInfoCopyWithImpl<$Res>
    extends _$UpdateInfoCopyWithImpl<$Res, _$_UpdateInfo>
    implements _$$_UpdateInfoCopyWith<$Res> {
  __$$_UpdateInfoCopyWithImpl(
      _$_UpdateInfo _value, $Res Function(_$_UpdateInfo) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requiredUpdate = null,
    Object? requiredIosVersion = null,
    Object? requiredAndroidVersion = null,
    Object? isUnderRepair = null,
    Object? underRepairComment = null,
  }) {
    return _then(_$_UpdateInfo(
      requiredUpdate: null == requiredUpdate
          ? _value.requiredUpdate
          : requiredUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      requiredIosVersion: null == requiredIosVersion
          ? _value.requiredIosVersion
          : requiredIosVersion // ignore: cast_nullable_to_non_nullable
              as String,
      requiredAndroidVersion: null == requiredAndroidVersion
          ? _value.requiredAndroidVersion
          : requiredAndroidVersion // ignore: cast_nullable_to_non_nullable
              as String,
      isUnderRepair: null == isUnderRepair
          ? _value.isUnderRepair
          : isUnderRepair // ignore: cast_nullable_to_non_nullable
              as bool,
      underRepairComment: null == underRepairComment
          ? _value.underRepairComment
          : underRepairComment // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_UpdateInfo implements _UpdateInfo {
  const _$_UpdateInfo(
      {required this.requiredUpdate,
      required this.requiredIosVersion,
      required this.requiredAndroidVersion,
      required this.isUnderRepair,
      required this.underRepairComment});

  factory _$_UpdateInfo.fromJson(Map<String, dynamic> json) =>
      _$$_UpdateInfoFromJson(json);

  @override
  final bool requiredUpdate;
  @override
  final String requiredIosVersion;
  @override
  final String requiredAndroidVersion;
  @override
  final bool isUnderRepair;
  @override
  final String underRepairComment;

  @override
  String toString() {
    return 'UpdateInfo(requiredUpdate: $requiredUpdate, requiredIosVersion: $requiredIosVersion, requiredAndroidVersion: $requiredAndroidVersion, isUnderRepair: $isUnderRepair, underRepairComment: $underRepairComment)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UpdateInfo &&
            (identical(other.requiredUpdate, requiredUpdate) ||
                other.requiredUpdate == requiredUpdate) &&
            (identical(other.requiredIosVersion, requiredIosVersion) ||
                other.requiredIosVersion == requiredIosVersion) &&
            (identical(other.requiredAndroidVersion, requiredAndroidVersion) ||
                other.requiredAndroidVersion == requiredAndroidVersion) &&
            (identical(other.isUnderRepair, isUnderRepair) ||
                other.isUnderRepair == isUnderRepair) &&
            (identical(other.underRepairComment, underRepairComment) ||
                other.underRepairComment == underRepairComment));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      requiredUpdate,
      requiredIosVersion,
      requiredAndroidVersion,
      isUnderRepair,
      underRepairComment);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UpdateInfoCopyWith<_$_UpdateInfo> get copyWith =>
      __$$_UpdateInfoCopyWithImpl<_$_UpdateInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UpdateInfoToJson(
      this,
    );
  }
}

abstract class _UpdateInfo implements UpdateInfo {
  const factory _UpdateInfo(
      {required final bool requiredUpdate,
      required final String requiredIosVersion,
      required final String requiredAndroidVersion,
      required final bool isUnderRepair,
      required final String underRepairComment}) = _$_UpdateInfo;

  factory _UpdateInfo.fromJson(Map<String, dynamic> json) =
      _$_UpdateInfo.fromJson;

  @override
  bool get requiredUpdate;
  @override
  String get requiredIosVersion;
  @override
  String get requiredAndroidVersion;
  @override
  bool get isUnderRepair;
  @override
  String get underRepairComment;
  @override
  @JsonKey(ignore: true)
  _$$_UpdateInfoCopyWith<_$_UpdateInfo> get copyWith =>
      throw _privateConstructorUsedError;
}
