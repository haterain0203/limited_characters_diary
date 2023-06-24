import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'analytics_service.dart';

final routeObserverProvider = Provider<MyRouteObserver>((ref) {
  final service = ref.watch(analyticsServiceProvider);
  return MyRouteObserver(service);
});

/// 既存のRouteObserverのdidPushメソッドをカスタマイズするためのクラス
class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  MyRouteObserver(this.service);
  final AnalyticsService service;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // 新しいルートがプッシュされたときに実行されるアクション
    // Firebase Analyticsにスクリーンビュー情報を送信する
    service.sendScreenView(route);
  }

}
