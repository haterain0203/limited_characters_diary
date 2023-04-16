import 'package:limited_characters_diary/feature/admob/ad_repository.dart';

class AdController {
  AdController({required this.repo});
  final AdRepository repo;

  Future<void> showInterstitialAdd() async {
    await repo.loadInterstitialAd();
  }

  Future<void> initInterstitialAdd() async {
    await repo.initInterstitialAd();
  }
}
