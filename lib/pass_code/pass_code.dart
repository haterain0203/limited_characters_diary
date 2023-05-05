import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'pass_code.freezed.dart';
part 'pass_code.g.dart';

@freezed
class PassCode with _$PassCode {
  const factory PassCode({
    required String passCode,
    required bool isPassCodeLock,
  }) = _PassCode;

  factory PassCode.fromJson(Map<String, dynamic> json) =>
      _$PassCodeFromJson(json);
}