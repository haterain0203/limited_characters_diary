import 'package:flutter/material.dart';
import 'package:limited_characters_diary/component/stadium_border_button.dart';
import 'package:sizer/sizer.dart';

class ForcedUpdateDialog extends StatelessWidget {
  const ForcedUpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '最新版がリリースされています。\nアップデートをお願いします。',
            style: TextStyle(
              fontSize: 13.sp,
            ),
          ),
        ),
        content: StadiumBorderButton(
          onPressed: () {
            //TODO ストアへ遷移
            Navigator.pop(context);
          },
          title: 'アプリストアへ',
        ),
      ),
    );
  }
}
