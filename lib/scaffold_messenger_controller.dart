import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/extension/string.dart';

final scaffoldMessengerKeyProvider =
    Provider((_) => GlobalKey<ScaffoldMessengerState>());

final navigatorKeyProvider = Provider((_) => GlobalKey<NavigatorState>());

final scaffoldMessengerControllerProvider = Provider.autoDispose(
  (ref) => ScaffoldMessengerController(
    scaffoldMessengerKey: ref.watch(scaffoldMessengerKeyProvider),
    navigatorKey: ref.watch(navigatorKeyProvider),
  ),
);

/// ツリー上部の [ScaffoldMessenger] 上でスナックバーやダイアログの表示を操作する。
class ScaffoldMessengerController {
  /// [ScaffoldMessengerController] を作成する。
  ScaffoldMessengerController({
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
    required GlobalKey<NavigatorState> navigatorKey,
  })  : _scaffoldMessengerKey = scaffoldMessengerKey,
        _navigatorKey = navigatorKey;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  final GlobalKey<NavigatorState> _navigatorKey;

  ScaffoldMessengerState get _currentState =>
      _scaffoldMessengerKey.currentState!;

  static const _defaultSnackBarBehavior = SnackBarBehavior.floating;

  static const _defaultSnackBarDuration = Duration(seconds: 3);

  static const _generalExceptionMessage = 'エラーが発生しました。';

  /// [Dialog] を表示する。
  Future<T?> showDialogByBuilder<T>({
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) =>
      showDialog<T>(
        context: _navigatorKey.currentContext!,
        barrierDismissible: barrierDismissible,
        builder: builder,
      );

  /// [BottomSheet] を表示する。
  Future<T?> showModalBottomSheetByBuilder<T>({
    required Widget Function(BuildContext) builder,
  }) =>
      showModalBottomSheet<T>(
        context: _scaffoldMessengerKey.currentContext!,
        builder: builder,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      );

  /// [SnackBar] を表示する。
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    String message, {
    bool removeCurrentSnackBar = true,
    Duration duration = _defaultSnackBarDuration,
  }) {
    if (removeCurrentSnackBar) {
      _currentState.removeCurrentSnackBar();
    }
    return _currentState.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: _defaultSnackBarBehavior,
        duration: duration,
      ),
    );
  }

  /// 一般的な [Exception] 起点で [SnackBar] を表示する。
  /// Dart の [Exception] 型の場合は toString() の冒頭を取り除いて
  /// 差し支えのないメッセージに置換しておく。
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showSnackBarByException(Exception e) {
    final message =
        e.toString().replaceAll('Exception: ', '').replaceAll('Exception', '');
    return showSnackBar(message.ifIsEmpty(_generalExceptionMessage));
  }

  /// [FirebaseException] 起点で [SnackBar] を表示する。
  ScaffoldFeatureController<SnackBar,
      SnackBarClosedReason> showSnackBarByFirebaseException(
    FirebaseException e,
  ) =>
      showSnackBar('[${e.code}]: ${e.message ?? 'FirebaseException が発生しました。'}');
}
