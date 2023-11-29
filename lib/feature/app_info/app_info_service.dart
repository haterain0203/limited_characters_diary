import 'package:device_info_plus/device_info_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final appInfoProvider =
    Provider.autoDispose<PackageInfo>((ref) => throw UnimplementedError());

final deviceInfoProvider =
    Provider.autoDispose<BaseDeviceInfo>((ref) => throw UnimplementedError());
