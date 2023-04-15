import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_info_repository.dart';

final appInfoRepoProvider = Provider((ref) => AppInfoRepository());

final appInfoProvider = FutureProvider<PackageInfo>((ref) async {
  final appInfoRepo = ref.read(appInfoRepoProvider);
  return appInfoRepo.fetchPackageInfo();
});
