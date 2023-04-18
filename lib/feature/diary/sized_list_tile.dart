import 'package:flutter/material.dart';

class SizedListTile extends StatelessWidget {
  const SizedListTile({
    this.height,
    this.tileColor,
    required this.leading,
    required this.title,
    super.key,
  });
  final double? height;
  final Color? tileColor;
  final Widget leading;
  final Widget title;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: height ?? 40,
          child: ColoredBox(
            color: tileColor ?? Colors.transparent,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    width: 40,
                    child: leading,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Expanded(
                    child: title,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
