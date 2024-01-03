import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    required this.buttonType,
    required this.text,
    required this.onPressed,
    super.key,
  });

  final Buttons buttonType;
  final String text;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: SignInButton(
        buttonType,
        text: text,
        shape: const StadiumBorder(),
        onPressed: onPressed,
      ),
    );
  }
}
