import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/admob/ad_service.dart';

final adControllerProvider = Provider(
  (ref) => AdController(
    service: ref.watch(adServiceProvider),
  ),
);

class AdController {
  AdController({required this.service});

  final AdService service;

  //全画面広告の表示
  Future<void> showInterstitialAdd() async {
    await service.loadInterstitialAd();
  }

  //全画面広告の取得
  Future<void> initInterstitialAdd() async {
    await service.initInterstitialAd();
  }

  Future<void> requestATT() async {
    await service.requestATT();
  }
}

/// 全画面広告表示を行ったか否か
///
/// 全画面広告実行時にinactiveになるようで、それにより全画面広告完了後にパスコードロック画面が表示されてしまう
/// 全画面広告実行時にはパスコードロック画面を表示しないようにするために使用
final isShownInterstitialAdProvider = StateProvider((ref) => false);
