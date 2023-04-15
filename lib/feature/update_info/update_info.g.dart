// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_UpdateInfo _$$_UpdateInfoFromJson(Map<String, dynamic> json) =>
    _$_UpdateInfo(
      requiredUpdate: json['requiredUpdate'] as bool,
      requiredIosVersion: json['requiredIosVersion'] as String,
      requiredAndroidVersion: json['requiredAndroidVersion'] as String,
      isUnderRepair: json['isUnderRepair'] as bool,
      underRepairComment: json['underRepairComment'] as String,
    );

Map<String, dynamic> _$$_UpdateInfoToJson(_$_UpdateInfo instance) =>
    <String, dynamic>{
      'requiredUpdate': instance.requiredUpdate,
      'requiredIosVersion': instance.requiredIosVersion,
      'requiredAndroidVersion': instance.requiredAndroidVersion,
      'isUnderRepair': instance.isUnderRepair,
      'underRepairComment': instance.underRepairComment,
    };
