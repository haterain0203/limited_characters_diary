import 'package:flutter/material.dart';
import 'package:limited_characters_diary/constant/constant.dart';

class SizedHeightListTile extends StatelessWidget {
  const SizedHeightListTile({
    required this.onTap,
    this.onLongPress,
    this.tileColor,
    required this.leading,
    required this.title,
    super.key,
  });
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
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
        height: Constant.sizedListTileHeight,
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
