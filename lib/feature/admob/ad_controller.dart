import 'package:limited_characters_diary/feature/admob/ad_repository.dart';

class AdController {
  AdController({required this.repo});
  final AdRepository repo;

  void showInterstitialAdd() {
    repo
      ..initInterstitialAd()
      ..loadInterstitialAd();
  }
}
