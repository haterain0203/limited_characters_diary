import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'date_controller.dart';

final selectedDateTimeProvider = StateProvider((ref) => DateTime.now());

final dateControllerProvider = Provider.autoDispose(
  (ref) => DateController(
    selectedDateTime: ref.watch(selectedDateTimeProvider),
    isJumpedToAroundToday: ref.watch(isJumpedToAroundTodayProvider),
  ),
);

final isJumpedToAroundTodayProvider = StateProvider((ref) => false);
