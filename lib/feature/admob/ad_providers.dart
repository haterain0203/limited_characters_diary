import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/admob/ad_controller.dart';
import 'package:limited_characters_diary/feature/admob/ad_repository.dart';

final adRepoProvider = Provider((ref) => AdRepository());

final adControllerProvider = Provider(
  (ref) => AdController(
    repo: ref.watch(adRepoProvider),
  ),
);
