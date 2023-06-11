import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/confidential.dart';

class AdService {
  AdService({
    required this.isShownInterstitialAdController,
  });
  final StateController<bool> isShownInterstitialAdController;

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
        //TODO check repository層がriveropodに依存するのはおかしいのではないか？
        // 全画面広告を閉じて以降、アプリをバックグラウンドに移動させた際、パスコードロックを正しく表示するため
        isShownInterstitialAdController.state = false;
        await ad.dispose();
        await initInterstitialAd();
      },
      onAdFailedToShowFullScreenContent:
          (InterstitialAd ad, AdError adError) async {
        await ad.dispose();
        await initInterstitialAd();
      },
    );

    //TODO check repository層がriveropodに依存するのはおかしいのではないか？
    // 全画面広告を表示する際、アプリがinactiveになるが、その際はパスコードロックを表示したくないためflagをtrueに
    isShownInterstitialAdController.state = true;

    await interstitialAd!.show();
    interstitialAd = null;
  }

  static String get appId {
    if (Platform.isAndroid) {
      return Confidential.adAppIdAndroid;
    } else if (Platform.isIOS) {
      return Confidential.adAppIdIos;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // static String get bannerAdUnitId {
  //   if (Platform.isAndroid) {
  //     //TODO テスト用IDから本番用に切り替える
  //     return 'ca-app-pub-3940256099942544/6300978111';
  //   } else if (Platform.isIOS) {
  //     //TODO テスト用IDから本番用に切り替える
  //     return 'ca-app-pub-3940256099942544/2934735716';
  //   } else {
  //     throw UnsupportedError('Unsupported platform');
  //   }
  // }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return Confidential.interstitialAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return Confidential.interstitialAdUnitIdIos;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // ATTが未設定の場合、ATT許可ダイアログを表示する
  Future<void> requestATT() async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }
}
