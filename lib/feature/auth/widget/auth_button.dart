import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/enum.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../auth_controller.dart';
import '../auth_service.dart';

/// 認証ボタンを提供するウィジェット。GoogleやAppleのサインイン、連携、連携解除をサポート。
class AuthButton extends HookConsumerWidget {
  /// Googleでのログイン用コンストラクタ。
  const AuthButton.googleLogin({
    this.buttonType = Buttons.google,
    this.socialAuthType = SocialAuthType.login,
    this.signInMethod = SignInMethod.google,
    super.key,
  });

  /// Googleアカウントとの連携用コンストラクタ。
  const AuthButton.googleLink({
    this.buttonType = Buttons.google,
    this.socialAuthType = SocialAuthType.link,
    this.signInMethod = SignInMethod.google,
    super.key,
  });

  /// Googleアカウントとの連携解除用コンストラクタ。
  const AuthButton.googleUnLink({
    this.buttonType = Buttons.google,
    this.socialAuthType = SocialAuthType.unLink,
    this.signInMethod = SignInMethod.google,
    super.key,
  });

  /// Appleでのログイン用コンストラクタ。
  const AuthButton.appleLogin({
    this.buttonType = Buttons.appleDark,
    this.socialAuthType = SocialAuthType.login,
    this.signInMethod = SignInMethod.apple,
    super.key,
  });

  /// Appleアカウントとの連携用コンストラクタ。
  const AuthButton.appleLink({
    this.buttonType = Buttons.appleDark,
    this.socialAuthType = SocialAuthType.link,
    this.signInMethod = SignInMethod.apple,
    super.key,
  });

  /// Appleアカウントとの連携解除用コンストラクタ。
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

  /// ボタンのテキストと押下時の動作を取得する。
  _AuthButtonContent _getAuthButtonContent({
    required WidgetRef ref,
    required SignInMethod signInMethod,
    required SocialAuthType socialAuthType,
  }) {
    return switch (socialAuthType) {
      // ログイン、連携、連携解除のそれぞれに応じてテキストと押下時の動作を設定する。
      SocialAuthType.login => _AuthButtonContent(
          buttonText: '${signInMethod.displayName}でサインイン',
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
          buttonText: '${signInMethod.displayName}アカウント連携',
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
            await ref.read(authControllerProvider).unLinkUserSocialLogin(
                  signInMethod: signInMethod,
                );
            ref.invalidate(linkedProvidersProvider);
          },
        ),
    };
  }
}

/// 認証ボタンのテキストと押されたときのアクションを格納するクラス。
class _AuthButtonContent {
  const _AuthButtonContent({
    required this.buttonText,
    required this.onPressed,
  });
  final String buttonText;
  final Future<void> Function() onPressed;
}
