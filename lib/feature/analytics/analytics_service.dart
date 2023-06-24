import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final firebaseAnalyticsProvider = Provider((_) {
  return FirebaseAnalytics.instance;
});

final analyticsServiceProvider = Provider(
  (ref) => AnalyticsService(analytics: ref.watch(firebaseAnalyticsProvider)),
);

class AnalyticsService {
  AnalyticsService({required this.analytics});
  final FirebaseAnalytics analytics;

  Future<void> sendLogEvent(String eventName) async {
    await analytics.logEvent(name: eventName);
  }

  Future<void> _sendScreenView(Route<dynamic> route) async {
    final screenName = route.settings.name;
    await analytics.setCurrentScreen(screenName: screenName);
  }
}

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
    service._sendScreenView(route);
  }

}
