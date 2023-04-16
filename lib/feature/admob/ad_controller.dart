import 'package:limited_characters_diary/feature/admob/ad_repository.dart';

class AdController {
  AdController({required this.repo});
  final AdRepository repo;

  //全画面広告の表示
  Future<void> showInterstitialAdd() async {
    await repo.loadInterstitialAd();
  }

  //全画面広告の取得
  Future<void> initInterstitialAdd() async {
    await repo.initInterstitialAd();
  }
}
