import 'package:flutter/material.dart';

class StadiumBorderButton extends StatelessWidget {
  const StadiumBorderButton({
    this.onPressed,
    this.title,
    super.key,
  });

  final VoidCallback? onPressed;
  final String? title;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ??
          () {
            Navigator.pop(context);
          },
      style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
      child: Text(title ?? '閉じる'),
    );
  }
}
