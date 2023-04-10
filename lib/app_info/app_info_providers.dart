import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/app_info/app_info_repository.dart';

final appInfoRepoProvider = Provider((ref) => AppInfoRepository());

final appInfoProvider = FutureProvider((ref) async {
  final appInfoRepo = ref.read(appInfoRepoProvider);
  return appInfoRepo.fetchPackageInfo();
});
