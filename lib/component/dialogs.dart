import 'package:flutter/material.dart';
import 'package:limited_characters_diary/component/stadium_border_button.dart';

class OnlyCloseDialog extends StatelessWidget {
  const OnlyCloseDialog({
    required this.title,
    this.content,
    super.key,
  });

  final String title;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content,
      actions: [
        StadiumBorderButton(
          onPressed: () {
            Navigator.pop(context);
          },
          title: '閉じる',
        ),
      ],
    );
  }
}
