import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdRepository {
  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;
  int maxFailedToAttempt = 3;
  int _numInterstitialLoadAttempt = 0;

  // 公式のexampleを参照して作成
  // https://pub.dev/packages/google_mobile_ads/example
  Future<void> initInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          interstitialAd = ad;
          _numInterstitialLoadAttempt = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _numInterstitialLoadAttempt++;
          interstitialAd = null;
          if (_numInterstitialLoadAttempt <= maxFailedToAttempt) {
            initInterstitialAd();
          }
        },
      ),
    );
  }

  Future<void> loadInterstitialAd() async {
    if (interstitialAd == null) {
      return;
    }
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) async {
        await ad.dispose();
        await initInterstitialAd();
      },
      onAdFailedToShowFullScreenContent:
          (InterstitialAd ad, AdError adError) async {
        await ad.dispose();
        await initInterstitialAd();
      },
    );
    await interstitialAd!.show();
    interstitialAd = null;
  }

  static String get appId {
    //TODO 本番用に切り替える
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544~3347511713';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544~1458002511';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      //TODO テスト用IDから本番用に切り替える
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      //TODO テスト用IDから本番用に切り替える
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      //TODO テスト用IDのため追って変更
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      //TODO テスト用IDのため追って変更
      return 'ca-app-pub-3940256099942544/4411468910';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
