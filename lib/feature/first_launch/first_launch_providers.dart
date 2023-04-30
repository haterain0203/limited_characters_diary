import 'package:hooks_riverpod/hooks_riverpod.dart';

final isFirstLaunchProvider = StateProvider<bool>((_) => false);

// 「WidgetsBinding.instance.addPostFrameCallback」は、
// ビルドするたびに呼び出されダイアログが複数重なってしまうため、
// 既にダイアログが開かれたかを判定するフラグを用意
final isOpenedFirstLaunchDialogProvider = StateProvider<bool>((_) => false);

/// アラーム設定を促すダイアログを自動表示させるかどうか
///
/// 初回起動かつ、アラーム設定ダイアログが表示されていない場合には、自動表示する
final isShowSetNotificationDialogOnLaunchProvider = Provider<bool>((ref) {
  final isFirstLaunch = ref.watch(isFirstLaunchProvider);
  if(!isFirstLaunch) {
    return false;
  }

  final isOpenedFirstLaunchDialog = ref.watch(isOpenedFirstLaunchDialogProvider);
  if(isOpenedFirstLaunchDialog) {
    return false;
  }

  return true;
});
