import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/enum.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../../component/dialog_utils.dart';
import '../auth_controller.dart';
import '../auth_service.dart';

class AuthButton extends HookConsumerWidget {
  const AuthButton.googleLogin({
    this.buttonType = Buttons.google,
    this.socialAuthType = SocialAuthType.login,
    this.signInMethod = SignInMethod.google,
    super.key,
  });

  const AuthButton.googleLink({
    this.buttonType = Buttons.google,
    this.socialAuthType = SocialAuthType.link,
    this.signInMethod = SignInMethod.google,
    super.key,
  });

  const AuthButton.googleUnLink({
    this.buttonType = Buttons.google,
    this.socialAuthType = SocialAuthType.unLink,
    this.signInMethod = SignInMethod.google,
    super.key,
  });

  const AuthButton.appleLogin({
    this.buttonType = Buttons.appleDark,
    this.socialAuthType = SocialAuthType.login,
    this.signInMethod = SignInMethod.apple,
    super.key,
  });

  const AuthButton.appleLink({
    this.buttonType = Buttons.appleDark,
    this.socialAuthType = SocialAuthType.link,
    this.signInMethod = SignInMethod.apple,
    super.key,
  });

  const AuthButton.appleUnLink({
    this.buttonType = Buttons.appleDark,
    this.socialAuthType = SocialAuthType.unLink,
    this.signInMethod = SignInMethod.apple,
    super.key,
  });

  final Buttons buttonType;
  final SocialAuthType socialAuthType;
  final SignInMethod signInMethod;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authButtonContent = _getAuthButtonContent(
      ref: ref,
      signInMethod: signInMethod,
      socialAuthType: socialAuthType,
    );
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: SignInButton(
        buttonType,
        text: authButtonContent.buttonText,
        shape: const StadiumBorder(),
        onPressed: authButtonContent.onPressed,
      ),
    );
  }

  _AuthButtonContent _getAuthButtonContent({
    required WidgetRef ref,
    required SignInMethod signInMethod,
    required SocialAuthType socialAuthType,
  }) {
    return switch (socialAuthType) {
      SocialAuthType.login => _AuthButtonContent(
          buttonText: '${signInMethod.name}でサインイン',
          onPressed: () async {
            return switch (signInMethod) {
              SignInMethod.google =>
                await ref.read(authControllerProvider).signInGoogleAndAddUser(),
              SignInMethod.apple =>
                await ref.read(authControllerProvider).signInAppleAndAddUser(),
            };
          },
        ),
      SocialAuthType.link => _AuthButtonContent(
          buttonText: '${signInMethod.name}アカウント連携',
          onPressed: () async {
            await ref.read(authControllerProvider).linkUserSocialLogin(
                  signInMethod: signInMethod,
                );
            ref.invalidate(linkedProvidersProvider);
          },
        ),
      SocialAuthType.unLink => _AuthButtonContent(
          buttonText: '連携済み',
          onPressed: () async {
            final result =
                await ref.read(dialogUtilsControllerProvider).showYesNoDialog();
            if (!result) {
              return;
            }
            await ref.read(authControllerProvider).unLinkUserSocialLogin(
                  signInMethod: signInMethod,
                );
            ref.invalidate(linkedProvidersProvider);
          },
        ),
    };
  }
}

class _AuthButtonContent {
  const _AuthButtonContent({
    required this.buttonText,
    required this.onPressed,
  });
  final String buttonText;
  final Future<void> Function() onPressed;
}
