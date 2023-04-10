import 'package:package_info_plus/package_info_plus.dart';

class AppVersionRepository {
  Future<PackageInfo> fetchPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }
}
