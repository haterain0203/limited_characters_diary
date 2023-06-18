import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final appInfoServiceProvider = Provider((ref) => AppInfoService());

class AppInfoService {
  Future<PackageInfo> fetchPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }
}

final appInfoProvider = FutureProvider<PackageInfo>((ref) async {
  final appInfoService = ref.watch(appInfoServiceProvider);
  return appInfoService.fetchPackageInfo();
});
