import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pass_code.freezed.dart';
part 'pass_code.g.dart';

@freezed
class PassCode with _$PassCode {
  const factory PassCode({
    // パスコードそのもの
    required String passCode,
    // パスコードロック設定のON/OFF
    required bool isPassCodeEnabled,
  }) = _PassCode;

  factory PassCode.fromJson(Map<String, dynamic> json) =>
      _$PassCodeFromJson(json);
}
