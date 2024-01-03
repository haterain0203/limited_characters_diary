import 'package:flutter/material.dart';
import 'package:limited_characters_diary/feature/auth/widget/login_button.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginButtonGoogle extends StatelessWidget {
  const LoginButtonGoogle.login({
    required this.onPressed,
    super.key,
  }) : text = 'Googleでサインイン';

  const LoginButtonGoogle.link({
    required this.onPressed,
    super.key,
  }) : text = 'Googleアカウントで続ける';

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return LoginButton(
      buttonType: Buttons.google,
      text: text,
      onPressed: onPressed,
    );
  }
}
