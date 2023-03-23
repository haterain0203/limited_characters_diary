import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

final todayProvider = Provider<DateTime>((ref) => DateTime.now());

final dayOfWeekProvider = Provider<String>((ref) {
  final today = ref.watch(todayProvider);
  final dayOfWeek = DateFormat.E('ja').format(today);
  return dayOfWeek;
});
