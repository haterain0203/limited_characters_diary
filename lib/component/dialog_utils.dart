import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../scaffold_messenger_controller.dart';

final dialogUtilsControllerProvider = Provider(
  (ref) => DialogUtilsController(
    context: ref.watch(navigatorKeyProvider).currentContext!,
  ),
);

class DialogUtilsController {
  DialogUtilsController({
    required this.context,
  });
  final BuildContext context;

  Future<void> showYesNoDialog({
    String? title,
    String? desc,
    String? buttonYesText = 'はい',
    String? buttonNoText = 'いいえ',
    required VoidCallback yesButtonOnPress,
    VoidCallback? noButtonOnPress,
  }) async {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.infoReverse,
      title: title,
      desc: desc,
      btnCancelText: buttonNoText,
      btnCancelOnPress: noButtonOnPress ?? () {},
      btnCancelColor: Colors.grey,
      btnOkText: buttonYesText,
      btnOkOnPress: yesButtonOnPress,
      btnOkColor: Theme.of(context).primaryColor,
    ).show();
  }

  Future<void> showErrorDialog({
    String? errorTitle,
    String? errorDetail,
  }) async {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      title: errorTitle ?? 'エラー',
      desc: errorDetail,
      btnCancelText: '閉じる',
      btnCancelOnPress: () {},
      //TODO
      // btnOkText: '問い合わせる',
      //TODO
      // btnOkOnPress: () {

      // }
    ).show();
  }
}
