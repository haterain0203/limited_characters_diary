import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_info.freezed.dart';
part 'update_info.g.dart';

@freezed
class UpdateInfo with _$UpdateInfo {
  const factory UpdateInfo({
    required bool requiredUpdate,
    required String requiredIosVersion,
    required String requiredAndroidVersion,
    required bool isUnderRepair,
    required String underRepairComment,
  }) = _UpdateInfo;

  factory UpdateInfo.fromJson(Map<String, dynamic> json) =>
      _$UpdateInfoFromJson(json);
}
