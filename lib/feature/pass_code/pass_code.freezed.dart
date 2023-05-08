// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pass_code.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PassCode _$PassCodeFromJson(Map<String, dynamic> json) {
  return _PassCode.fromJson(json);
}

/// @nodoc
mixin _$PassCode {
// パスコードそのもの
  String get passCode =>
      throw _privateConstructorUsedError; // パスコードロック設定のON/OFF
  bool get isPassCodeEnabled => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PassCodeCopyWith<PassCode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PassCodeCopyWith<$Res> {
  factory $PassCodeCopyWith(PassCode value, $Res Function(PassCode) then) =
      _$PassCodeCopyWithImpl<$Res, PassCode>;
  @useResult
  $Res call({String passCode, bool isPassCodeEnabled});
}

/// @nodoc
class _$PassCodeCopyWithImpl<$Res, $Val extends PassCode>
    implements $PassCodeCopyWith<$Res> {
  _$PassCodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? passCode = null,
    Object? isPassCodeEnabled = null,
  }) {
    return _then(_value.copyWith(
      passCode: null == passCode
          ? _value.passCode
          : passCode // ignore: cast_nullable_to_non_nullable
              as String,
      isPassCodeEnabled: null == isPassCodeEnabled
          ? _value.isPassCodeEnabled
          : isPassCodeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PassCodeCopyWith<$Res> implements $PassCodeCopyWith<$Res> {
  factory _$$_PassCodeCopyWith(
          _$_PassCode value, $Res Function(_$_PassCode) then) =
      __$$_PassCodeCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String passCode, bool isPassCodeEnabled});
}

/// @nodoc
class __$$_PassCodeCopyWithImpl<$Res>
    extends _$PassCodeCopyWithImpl<$Res, _$_PassCode>
    implements _$$_PassCodeCopyWith<$Res> {
  __$$_PassCodeCopyWithImpl(
      _$_PassCode _value, $Res Function(_$_PassCode) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? passCode = null,
    Object? isPassCodeEnabled = null,
  }) {
    return _then(_$_PassCode(
      passCode: null == passCode
          ? _value.passCode
          : passCode // ignore: cast_nullable_to_non_nullable
              as String,
      isPassCodeEnabled: null == isPassCodeEnabled
          ? _value.isPassCodeEnabled
          : isPassCodeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PassCode with DiagnosticableTreeMixin implements _PassCode {
  const _$_PassCode({required this.passCode, required this.isPassCodeEnabled});

  factory _$_PassCode.fromJson(Map<String, dynamic> json) =>
      _$$_PassCodeFromJson(json);

// パスコードそのもの
  @override
  final String passCode;
// パスコードロック設定のON/OFF
  @override
  final bool isPassCodeEnabled;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PassCode(passCode: $passCode, isPassCodeEnabled: $isPassCodeEnabled)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PassCode'))
      ..add(DiagnosticsProperty('passCode', passCode))
      ..add(DiagnosticsProperty('isPassCodeEnabled', isPassCodeEnabled));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PassCode &&
            (identical(other.passCode, passCode) ||
                other.passCode == passCode) &&
            (identical(other.isPassCodeEnabled, isPassCodeEnabled) ||
                other.isPassCodeEnabled == isPassCodeEnabled));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, passCode, isPassCodeEnabled);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PassCodeCopyWith<_$_PassCode> get copyWith =>
      __$$_PassCodeCopyWithImpl<_$_PassCode>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PassCodeToJson(
      this,
    );
  }
}

abstract class _PassCode implements PassCode {
  const factory _PassCode(
      {required final String passCode,
      required final bool isPassCodeEnabled}) = _$_PassCode;

  factory _PassCode.fromJson(Map<String, dynamic> json) = _$_PassCode.fromJson;

  @override // パスコードそのもの
  String get passCode;
  @override // パスコードロック設定のON/OFF
  bool get isPassCodeEnabled;
  @override
  @JsonKey(ignore: true)
  _$$_PassCodeCopyWith<_$_PassCode> get copyWith =>
      throw _privateConstructorUsedError;
}
