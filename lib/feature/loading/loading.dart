import 'package:flutter/material.dart';

/// 二度押しを防止したいときなどにアプリ全体に重ねるローディング UI.
class OverlayLoading extends StatelessWidget {
  const OverlayLoading({
    super.key,
    this.backgroundColor = Colors.black54,
  });

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: const SizedBox.expand(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
