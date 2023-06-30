import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/analytics/analytics_service.dart';

final analyticsContollerProvider = Provider(
  (ref) => AnalyticsController(
    service: ref.watch(analyticsServiceProvider),
  ),
);

class AnalyticsController {
  AnalyticsController({
    required this.service,
  });

  final AnalyticsService service;

  Future<void> sendLogEvent(String eventName) async {
    await service.sendLogEvent(eventName);
  }
}
