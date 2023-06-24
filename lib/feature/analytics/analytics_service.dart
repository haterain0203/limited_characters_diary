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

  Future<void> sendScreenView(Route<dynamic> route) async {
    final screenName = route.settings.name;
    await analytics.setCurrentScreen(screenName: screenName);
  }
}
