enum InputDiaryType {
  add,
  update,
}

enum NotificationDialogTrigger {
  onFirstLaunch,
  userAction,
}

/// Firebase Console の Authentication で設定できるサインイン方法の種別。
enum SignInMethod {
  google(displayName: 'Google'),
  apple(displayName: 'Apple'),
  ;

  const SignInMethod({required this.displayName});
  final String displayName;
}

/// ソーシャル認証の種別。
enum SocialAuthType {
  login,
  link,
  unLink,
  ;
}
