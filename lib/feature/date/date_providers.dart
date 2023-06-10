import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'date_controller.dart';

final selectedDateTimeProvider = StateProvider((ref) => DateTime.now());

final dateControllerProvider = Provider.autoDispose(
  (ref) => DateController(
    selectedDateTime: ref.watch(selectedDateTimeProvider),
    hasJumpedToAroundToday: ref.watch(hasJumpedToAroundTodayProvider),
  ),
);

final hasJumpedToAroundTodayProvider = StateProvider((ref) => false);
