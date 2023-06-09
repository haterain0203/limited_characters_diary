import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:limited_characters_diary/confidential.dart';

// 参考にしたURL
// https://zenn.dev/kazutxt/books/flutter_practice_introduction/viewer/38_chapter4_admob
class AdBanner extends StatelessWidget {
  const AdBanner({
    super.key,
    required this.size, // サイズは利用時に指定
  });
  final AdSize size;
  @override
  Widget build(BuildContext context) {
    // AndroidかiOSを前提とする
    final banner = BannerAd(
      // サイズ
      size: size,
      // 広告ユニットID
      adUnitId: Platform.isAndroid
          ? Confidential.bannerAdUnitIdAndroid
          : Confidential.bannerAdUnitIdIos,
      // イベントのコールバック
      listener: const BannerAdListener(
          // 未使用のためコメントアウト
          // onAdLoaded: (Ad ad) => print('Ad loaded.'),
          // onAdFailedToLoad: (Ad ad, LoadAdError error) {
          //   print('Ad failed to load: $error');
          // },
          // onAdOpened: (Ad ad) => print('Ad opened.'),
          // onAdClosed: (Ad ad) => print('Ad closed.'),
          ),
      // リクエストはデフォルトを使う
      request: const AdRequest(),
    )
      // 表示を行うloadをつける
      ..load();
    // 戻り値はSizedBoxで包んで返す
    return SizedBox(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
  }
}
