import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/admob/ad_controller.dart';
import 'package:limited_characters_diary/feature/admob/ad_repository.dart';

final adRepoProvider = Provider((ref) => AdRepository());

final adControllerProvider = Provider(
  (ref) => AdController(
    repo: ref.watch(adRepoProvider),
  ),
);

/// 全画面広告表示を行ったか否か
///
/// 全画面広告実行時にinactiveになるようで、それにより全画面広告完了後にパスコードロック画面が表示されてしまう
/// 全画面広告実行時にはパスコードロック画面を表示しないようにするために使用
final isShownInterstitialAdProvider = StateProvider((ref) => false);
