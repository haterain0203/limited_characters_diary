import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../scaffold_messanger_controller.dart';

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
