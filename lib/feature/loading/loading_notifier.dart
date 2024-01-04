import 'package:hooks_riverpod/hooks_riverpod.dart';

final loadingNotifierProvider =
    NotifierProvider.autoDispose<LoadingNotifier, bool>(LoadingNotifier.new);

class LoadingNotifier extends AutoDisposeNotifier<bool> {
  @override
  bool build() {
    return false;
  }

  void startLoading() {
    state = true;
  }

  void endLoading() {
    state = false;
  }
}
