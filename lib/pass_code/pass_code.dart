import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'pass_code.freezed.dart';
part 'pass_code.g.dart';

@freezed
class PassCode with _$PassCode {
  const factory PassCode({
    // パスコードそのもの
    required String passCode,
    // パスコードロック設定のON/OFF
    required bool isPassCodeEnabled,
    // 今現在画面がロックされているかどうか
    required bool isScreenLocked,
  }) = _PassCode;

  factory PassCode.fromJson(Map<String, dynamic> json) =>
      _$PassCodeFromJson(json);
}