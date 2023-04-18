import 'package:flutter/material.dart';

class SizedListTile extends StatelessWidget {
  const SizedListTile({
    required this.onTap,
    this.onLongPress,
    this.height,
    this.tileColor,
    required this.leading,
    required this.title,
    super.key,
  });
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double? height;
  final Color? tileColor;
  final Widget leading;
  final Widget title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: double.infinity,
        height: height ?? 32,
        child: ColoredBox(
          color: tileColor ?? Colors.transparent,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 60,
                  child: leading,
                ),
              ),
              title,
            ],
          ),
        ),
      ),
    );
  }
}
