import 'package:flutter/material.dart';

class StadiumBorderButton extends StatelessWidget {
  const StadiumBorderButton({
    this.onPressed,
    this.title,
    this.backgroundColor,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget? title;
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ??
          () {
            Navigator.pop(context);
          },
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      ),
      child: title ?? const Text('閉じる'),
    );
  }
}
