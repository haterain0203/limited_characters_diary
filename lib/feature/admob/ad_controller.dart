import 'package:limited_characters_diary/feature/admob/ad_repository.dart';

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
