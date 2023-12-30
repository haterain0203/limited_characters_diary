import 'package:flutter/material.dart';
import 'package:limited_characters_diary/feature/auth/widget/login_button.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginButtonApple extends StatelessWidget {
  const LoginButtonApple.login({
    required this.onPressed,
    super.key,
  }) : text = 'Appleでサインイン';

  const LoginButtonApple.link({
    required this.onPressed,
    super.key,
  }) : text = 'Appleアカウントで続ける';

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return LoginButton(
      buttonType: Buttons.appleDark,
      text: text,
      onPressed: onPressed,
    );
  }
}
