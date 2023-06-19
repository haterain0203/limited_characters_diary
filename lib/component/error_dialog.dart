import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog({
  required BuildContext context,
  String? errorMessage,
  String? errorDetail,
}) {
  return AwesomeDialog(
    context: context,
    dialogType: DialogType.error,
    title: errorMessage ?? 'エラーが発生しました',
    desc: errorDetail,
    btnCancelText: '閉じる',
    btnCancelOnPress: () {},
  ).show();
}
